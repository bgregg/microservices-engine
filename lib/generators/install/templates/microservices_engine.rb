# frozen_string_literal: true
require 'net/http'
config_file = 'config/mse_router_info.yml'

unless File.file?(config_file) # I want to say rubocop dislikes `unless`
  raise IOError, '[MSE] > No router configuration YAML file found'
end

config_data = YAML.load_file(config_file)

if [config_data['name'], config_data['uri']].any?(&:blank?)
  raise '[MSE] > Please fill out config/mse_router_info.yml'
end

# Make sure the URI ends with a / character
uri = config['router_uri']
uri += '/' if uri[-1] != '/'

res = Net::HTTP.post_form(
  URI(uri),
  'ph_name': config_data['name'],
  'ph_content': config_data['accessible_models']
)

raise '[MSE] > The router API response was invalid' if res.code != '200'
# TODO
# Verify that the contents of the response are what we expect to happen
