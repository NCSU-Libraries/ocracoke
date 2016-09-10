require_relative 'boot'

require 'rails/all'
# require 'rails'
# # require "active_record/railtie"
# # require "active_model/railtie"
# require "action_controller/railtie"
# require "action_view/railtie"
# require "action_mailer/railtie"
# require "rails/test_unit/railtie"
# require "active_job/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module IiifSearchInside
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.api_tokens = config_for(:api_tokens)

    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('app/processing_helpers')
    config.autoload_paths << Rails.root.join('app/processors')

    config.action_dispatch.default_headers = {
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Request-Method' => 'GET, PATCH, PUT, POST, OPTIONS, DELETE',
        'Access-Control-Allow-Headers:' => 'Origin, X-Requested-With, Content-Type, Accept'
    }

    config.iiifsi = config_for(:iiifsi)
    config.active_job.queue_adapter = :resque
  end
end
