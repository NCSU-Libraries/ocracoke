namespace :ocracoke do
  namespace :solr do

    task load_config_backup: :environment do |t|
      http = HTTPClient.new
      schema_url = File.join(Rails.configuration.ocracoke['solr_url'], 'schema')
      headers = { 'Content-Type' => 'application/json' }

      fields_yaml_path = File.join(Rails.root, 'config/solr/fields.yml')
      fields = YAML.load_file(fields_yaml_path)

      fields.each do |name, values|
        field = values.merge(name: name)
        request_field = {'add-field' => [field]}
        pp request_field
        response = http.post schema_url, request_field.to_json, headers
        puts response.body
        if response.status != 200
          request_field = {'replace-field' => [field]}
          response = http.post schema_url, request_field.to_json, headers
          puts response.body
        end
        puts "\n\n=======\n\n"
      end
    end

  end
end
