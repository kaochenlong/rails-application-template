require "fileutils"
require "shellwords"

def source_paths
  [__dir__]
end

def add_gems
  gem 'bootstrap', '~> 4.1', '>= 4.1.3'
  gem 'devise', '~> 4.5'
  gem 'jquery-rails', '~> 4.3', '>= 4.3.3'
  gem 'simple_form', '~> 4.0', '>= 4.0.1'

  gem_group :development, :test do
    gem 'rspec-rails', '~> 3.8'
    gem 'pry-byebug', '~> 3.6'
    gem 'faker', '~> 1.9', '>= 1.9.1'
    gem 'factory_bot', '~> 4.11', '>= 4.11.1'
  end
end

def install_simple_form
  generate "simple_form:install --bootstrap"
end

def add_rspec_settings
  # install rspec
  generate "rspec:install"
  run "bundle binstubs rspec-core"

  # remove original test folder
  run "rm -rf test"

  # add configs for rspec
  insert_into_file(
    "spec/rails_helper.rb",
    "\n  config.include FactoryBot::Syntax::Methods\n  config.include Devise::TestHelpers, type: :controller\n  config.include Warden::Test::Helpers",

    after: "RSpec.configure do |config|"
  )

  gsub_file "spec/rails_helper.rb", /  # Remove this line(.|\n)*fixtures"\n/, ""
end

def add_application_config
  insert_into_file(
    "config/application.rb",
    "\n\n    config.generators do |g|\n      g.stylesheets false\n      g.javascripts false\n      g.test_framework false\n      g.helper false\n    end",
    after: "config.load_defaults 5.2"
  )
end

def stop_spring
  run "spring stop"
end

def add_bootstrap
  # remove original application CSS
  run "mv app/assets/stylesheets/application.css app/assets/stylesheets/application.scss"

  insert_into_file(
    "app/assets/stylesheets/application.scss",
    %Q(\n@import "bootstrap";),
    after: " */"
  )

  # add bootstrap JS
  insert_into_file(
    "app/assets/javascripts/application.js",
    "\n//= require jquery\n//= require popper\n//= require bootstrap",
    after: "//= require rails-ujs"
  )

  # copy shared files
  copy_file "shared/_navbar.html.erb", "app/views/shared/_navbar.html.erb"

  # add css for layout
  gsub_file "app/views/layouts/application.html.erb",
    /<%= yield %>/,
    %Q(<%= render "shared/navbar" %>\n    <div class="container">\n      <%= yield %>\n    </div>)
end

def add_homepage
  generate(:controller, "pages")
  add_file "app/views/pages/home.html.erb", "<h1>Hi, You, Have a lovely day!</h1>"
  route %Q(root "pages#home")
end

def rails_setup
  rails_command("db:migrate")
end

add_gems

after_bundle do
  stop_spring
  add_bootstrap
  install_simple_form
  add_rspec_settings
  add_application_config
  add_homepage
  rails_setup

  git :init
  git add: "."
  git commit: "-m 'initial commit'"

  puts "\n\n================="
  puts " Happy Hacking :)"
  puts "================="
end
