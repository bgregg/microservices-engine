require 'net/http'
config_file = 'config/mse_router_info.yml'

unless File.file?(config_file) # I want to say rubocop dislikes `unless`
  raise IOError.new('[MSE] > No router configuration YAML file found')
end

config_data = YAML.load_file(config_file)

if [config_data['name'], config_data['uri']].any? { |v| v.blank? }
  raise StandardError.new('[MSE] > Please fill out config/mse_router_info.yml')
end

res = Net::HTTP.post_form(
                  URI(config['router_uri']),
                  {
                    'ph_name': config_data['name'],
                    'ph_content': config_data['accessible_models']
                  }
                )

if res.code == "200"
  # TODO
  # Verify that the contents of the response are what we expect to happen

  puts 'We did it!'
else
  raise StandardError.new("[MSE] > The router API response was invalid")
end
