// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "src/turbo_error"

// We can't use session drive, since our existing js doesn't expect it
Turbo.session.drive = false
