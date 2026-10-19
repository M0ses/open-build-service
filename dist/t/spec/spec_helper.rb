# OBS Appliance spec helper.
# dist/t/spec/spec_helper.rb
# Absolute top of the file - Line 1

# Force Ruby to find vendored gems inside the Kanku sandbox directory layout
Dir[File.expand_path('../vendor/bundle/ruby/*/gems/*/lib', __dir__)].each do |path|
  $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
end

ENV['RAILS_ENV'] ||= 'test'

# Require supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each { |f| require f }

# Now require it directly bypassing bundler's strict isolation
require 'cuprite'

ENV['RAILS_ENV'] ||= 'test'

# for capybara rspec support
require 'support/capybara'
require 'bundler/setup'

SCREENSHOT_DIR = ENV.fetch('RSPEC_RESULT_DIR', '/tmp/rspec_screens').freeze


RSpec.configure do |config|
  config.before(:suite) do
    FileUtils.rm_rf(SCREENSHOT_DIR)
    FileUtils.mkdir_p(SCREENSHOT_DIR)
  end
  config.after do |example|
    if example.exception
      take_screenshot(example)
      dump_page(example)
    end
  end
  config.fail_fast = 1
end

def dump_page(example)
  filename = File.basename(example.metadata[:file_path])
  line_number = example.metadata[:line_number]
  dump_name = "dump-#{filename}-#{line_number}.html"
  dump_path = File.join(SCREENSHOT_DIR, dump_name)
  page.save_page(dump_path)
end

def take_screenshot(example)
  filename = File.basename(example.metadata[:file_path])
  line_number = example.metadata[:line_number]
  screenshot_name = "screenshot-#{filename}-#{line_number}.png"
  screenshot_path = File.join(SCREENSHOT_DIR, screenshot_name)
  page.save_screenshot(screenshot_path, full: true)
end

def login
  visit '/session/new'
  within('#loginform') do
    fill_in 'user-login', with: 'Admin'
    fill_in 'user-password', with: 'opensuse'
    click_button('Log In')
  end
  expect(page).to have_link('top-navigation-profile-dropdown')
end

def logout
  click_link('top-navigation-profile-dropdown')
  within('#top-navigation-area') do
    click_link('Logout')
  end
  expect(page).to have_no_link('top-navigation-profile-dropdown')
end
