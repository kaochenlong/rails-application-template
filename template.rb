require "fileutils"
require "shellwords"

def add_gems
  gem 'bootstrap', '~> 4.1', '>= 4.1.3'
  gem 'devise', '~> 4.5'
  gem 'jquery-rails', '~> 4.3', '>= 4.3.3'
end

def stop_spring
  run "spring stop"
end

def add_bootstrap
  # remove original application CSS
  run "rm app/assets/stylesheets/application.css"

  # add bootstrap JS
  insert_into_file(
    "app/assets/javascripts/application.js",
    "\n//= require jquery\n//= require popper\n//= require bootstrap\n//= require data-confirm-modal\n//= require local-time",
    after: "//= require rails-ujs"
  )
end

add_gems

after_bundle do
  stop_spring
  add_bootstrap

  git :init
  git add: "."
  git commit: %Q{ -m 'initial commit' }
end