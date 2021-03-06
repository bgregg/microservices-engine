# frozen_string_literal: true
require 'net/http'

module MicroservicesEngine
  class Initializer
    CONFIG_FILE = 'config/mse_router_info.yml'

    class << self
      def initialize!
        unless ENV.key? 'DISABLE_ROUTER_CHECKIN'
          check_for_config_file! CONFIG_FILE
          config_data = YAML.load_file CONFIG_FILE
          response = check_in_with_router using: config_data
          raise 'The router API response was invalid' if response.code != '200'
          response_data = JSON.parse response.body
          update_connections_database with: response_data
        end
      end

      def check_for_config_file!(filename)
        unless File.file? filename
          raise IOError, "No router configuration file found at #{filename}"
        end
      end

      def check_in_with_router(options = {})
        if options.key? :using
          config_data = options[:using]
          service_name = config_data.fetch('name'){  report_missing_config_key 'name' }
          service_url = config_data.fetch('uri'){ report_missing_config_key 'uri' }
          router_url = config_data.fetch('router_uri'){ report_missing_config_key 'router_uri' }
          security_token = config_data.fetch('security_token'){ report_missing_config_key 'security_token' }

          router_url = router_url + '/services/register'

          Net::HTTP.post_form(
            URI.parse(router_url),
            name: service_name,
            url: service_url,
            models: config_data['accessible_models'],
            security_token: security_token
          )
        end
      end

      def report_missing_config_key(key)
        raise ArgumentError, "Missing key #{key} in #{CONFIG_FILE}"
      end

      def update_connections_database(options = {})
        if options.key? :with
          response_data = options[:with]
          MicroservicesEngine::Connection.destroy_all
          response_data.each do |service|
            if service['models'].present?
              url = service['url']
              service['models'].each do |model|
                object = model['name']
                MicroservicesEngine::Connection.create!  url: url, object: object
              end
            end
          end
        end
      end
    end
  end
end

MicroservicesEngine::Initializer.initialize! unless ENV['RAILS_ENV'] == 'test'
