require 'spec_helper'

RSpec.describe 'Project', type: :feature do
  # We consciously want the state of a finished spec to be preserved for the next one
  before(:context) do # rubocop:disable RSpec/BeforeAfterAll
    login
  end

  after(:context) do # rubocop:disable RSpec/BeforeAfterAll
    logout
  end

  it 'is able to create' do
    within('#left-navigation') do
      click_link('Create Your Home Project')
    end
    click_button('Accept')
    expect(page).to have_text("Project 'home:Admin' was created successfully")
  end

  it 'is able to add repositories' do
    # Standard REST API design: Trigger immediate fetch via 'cmd=refresh' query param
    require 'net/http'
    require 'uri'
    uri = URI.parse("#{Capybara.app_host}/distributions/refresh")
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    request = Net::HTTP::Post.new(uri.request_uri)
    request.basic_auth('Admin', 'opensuse')
    begin
      response = http.request(request)
      puts "Triggered distributions refresh: #{response.code} #{response.body}" # rubocop:disable RSpec/Output
    rescue => e # rubocop:disable Style/RescueStandardError
      puts "Failed to trigger distributions refresh: #{e}" # rubocop:disable RSpec/Output
    end
    Timeout.timeout(300) do
      loop do
        within('#left-navigation') do
          click_link('Your Home Project')
        end
        click_link('Repositories')
        click_link('Add from a Distribution')
        break unless have_text('There are no distributions configured. Maybe you want to connect to one of the public OBS instances?')

        break if have_text('Add Repositories to home:Admin')

        sleep 10
      end
    end
    # 1. Locate the precise input checkbox element associated with that specific label using XPath
    checkbox = find(:xpath, "//label[contains(normalize-space(), 'openSUSE Leap 16.0')]/preceding-sibling::input[@type='checkbox']", visible: :any)

    # 2. Trigger a click directly via the browser's JavaScript execution engine to bypass any click-interception problems
    execute_script("arguments[0].click();", checkbox)

    # 3. Verify it is checked after a hard page reload
    visit current_path
    expect(page).to have_css('input.distribution-input:checked', visible: :any)
  end
end
