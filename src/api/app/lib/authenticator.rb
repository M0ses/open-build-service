require 'api_error'

class Authenticator
  class AuthenticationRequiredError < APIError
    setup 401, 'Authentication required'
  end

  class InactiveUserError < APIError
    setup 403
  end

  class UnconfirmedUserError < APIError
    setup 403
  end

  class AdminUserRequiredError < APIError
    setup('put_request_no_permission', 403)
  end

  attr_reader :request, :session, :http_user

  def initialize(request, session, response)
    @response = response
    @request = request
    @session = session
    @http_user = nil
  end

  def extract_user
    if ::Configuration.proxy_auth_mode_enabled?
      extract_proxy_user
    else
      extract_auth_user
      @http_user = User.find_with_credentials(@login, @passwd) if @login && @passwd
    end

    @http_user = User.find_by_login(session[:login]) if !@http_user && session[:login]

    check_extracted_user
  end

  # We allow anonymous user only for rare special operations (if configured) but we require
  # a valid account for all other operations.
  # For this rare special operations we simply skip the require login before filter!
  # At the moment these operations are the /public, /trigger and /about controller actions.
  def require_login
    raise AuthenticationRequiredError unless User.session
  end

  def require_admin
    Rails.logger.debug { "Checking for Admin role for user #{@http_user.login}" }
    return if @http_user.admin?

    Rails.logger.debug 'not granted!'
    raise AdminUserRequiredError, 'Requires admin privileges'
  end

  def authorization_infos
    # 1. try to get it where mod_rewrite might have put it
    # 2. for Apache/mod_fastcgi with -pass-header Authorization
    # 3. regular location
    %w[X-HTTP_AUTHORIZATION Authorization HTTP_AUTHORIZATION].each do |header|
      return request.env[header].to_s.split if request.env.key?(header)
    end
    nil
  end

  private

  def raise_and_invalidate(authorization, message = '')
    @response.headers['WWW-Authenticate'] = authorization.join(' ')
    raise AuthenticationRequiredError, message
  end

  def extract_basic_user(authorization)
    @login, @passwd = Base64.decode64(authorization[1]).split(':', 2)[0..1]

    # set password to the empty string in case no password is transmitted in the auth string
    @passwd ||= ''
  end

  def extract_proxy_user
    proxy_user = request.env['HTTP_X_USERNAME']

    # we're using a login proxy, there is no need to authenticate the user from the credentials
    # However we have to care for the status of the user that must not be unconfirmed or proxy requested
    if proxy_user
      @http_user = User.find_by_login(proxy_user)

      # If we do not find a User here, we need to create a user and wait for
      # the confirmation by the user and the BS Admin Team.
      unless @http_user
        if ::Configuration.registration == 'deny'
          Rails.logger.debug('No user found in database, creation disabled')
          raise AuthenticationRequiredError, "User '#{proxy_user}' does not exist"
        end

        @http_user = User.create_user_with_fake_pw!(login: proxy_user, state: User.default_user_state)
      end

      @http_user.update_login_values(request.env)
    else
      Rails.logger.error 'No X-username header was sent by login proxy!'
    end
  end

  def extract_auth_user
    authorization = authorization_infos
    # privacy! logger.debug( "AUTH: #{authorization.inspect}" )
    if authorization
      # logger.debug( "AUTH2: #{authorization}" )
      if authorization[0] == 'Basic'
        extract_basic_user(authorization)
      else
        Rails.logger.debug { "Unsupported authentication string '#{authorization[0]}' received." }
      end
    else
      Rails.logger.debug 'No authentication string was received.'
    end
  end

  def check_extracted_user
    unless @http_user
      if @login.blank?
        return true if check_for_anonymous_user

        raise AuthenticationRequiredError
      end
      raise AuthenticationRequiredError, "Unknown user '#{@login}' or invalid password"
    end

    if @http_user.state == 'unconfirmed'
      raise UnconfirmedUserError, 'User is registered but not yet approved. Your account ' \
                                  'is a registered account, but it is not yet approved for the OBS by admin.'
    end

    User.session = @http_user

    if @http_user.state == 'confirmed'
      Rails.logger.debug { "USER found: #{@http_user.login}" }
      return
    end

    raise InactiveUserError, 'User is registered but not in confirmed state. Your account ' \
                             'is a registered account, but it is in a not active state.'
  end

  # set the nobody user if a user agent is present in anonymous mode
  def check_for_anonymous_user
    return false unless ::Configuration.anonymous && request.user_agent

    @http_user = User.find_nobody!
    User.session = @http_user
    true
  end
end
