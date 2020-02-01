class SolrConfigLoader

  def initialize
    @http = HTTPClient.new
    @field_types = YAML.load_file(field_types_yaml_path)
    @fields = YAML.load_file(fields_yaml_path)
    @copy_fields = YAML.load_file(copy_fields_yaml_path)
    @search_components = YAML.load_file(search_components_yaml_path)
    @request_handlers = YAML.load_file(request_handlers_yaml_path)
    @common_properties = YAML.load_file(common_properties_yaml_path)
  end

  def load_all
    load_field_types
    load_fields
    load_copy_fields
    load_search_components
    load_request_handlers
    load_common_properties
  end

  def load_field_types
    @field_types.each do |field_type|
      add_field_type(field_type)
    end
  end

  def add_field_type(field_type)
    request_add_and_retry_replace(schema_url, field_type, 'add-field-type', 'replace-field-type')
  end

  def load_fields
    @fields.each do |field|
      add_field(field)
    end
  end

  def add_field(field)
    request_add_and_retry_replace(schema_url, field, 'add-field', 'replace-field')
  end

  def load_copy_fields
    @copy_fields.each do |copy_field|
      add_copy_field(copy_field)
    end
  end

  def add_copy_field(copy_field)
    request_add_and_retry_replace(schema_url, copy_field, 'add-copy-field', nil)
  end

  def load_search_components
    @search_components.each do |search_component|
      add_search_component(search_component)
    end
  end

  def add_search_component(search_component)
    request_add_and_retry_replace(config_url, search_component, 'add-searchcomponent', 'update-searchcomponent')
  end

  def load_request_handlers
    @request_handlers.each do |request_handler|
      add_request_handler(request_handler)
    end
  end

  def add_request_handler(request_handler)
    request_add_and_retry_replace(config_url, request_handler, 'add-requesthandler', 'update-requesthandler')
  end

  def load_common_properties
    @common_properties.each do |common_property|
      add_common_property(common_property)
    end
  end

  def add_common_property(common_property)
    request_add_and_retry_replace(config_url, common_property, 'set-property', nil)
  end

  def request_add_and_retry_replace(url, data, add, replace)
    add_data = {add => data}
    puts "Add data:"
    pp add_data
    response = @http.post url, add_data.to_json, headers
    puts response.body
    if replace && response.status != 200
      replace_data = {replace => data}
      puts "REPLACE DATA:"
      pp replace_data
      response = @http.post url, replace_data.to_json, headers
      puts response.body
    end
    puts "\n\n\n"
  end

  def schema_url
    File.join(Rails.configuration.ocracoke['solr_url'], 'schema')
  end

  def config_url
    File.join(Rails.configuration.ocracoke['solr_url'], 'config')
  end

  def headers
    { 'Content-Type' => 'application/json' }
  end

  def full_yaml_path(filename)
    File.join(Rails.root, "config/solr/#{filename}.yml")
  end

  def fields_yaml_path
    full_yaml_path('fields')
  end

  def field_types_yaml_path
    full_yaml_path('field_types')
  end

  def copy_fields_yaml_path
    full_yaml_path('copy_fields')
  end

  def request_handlers_yaml_path
    full_yaml_path('request_handlers')
  end

  def search_components_yaml_path
    full_yaml_path('search_components')
  end

  def common_properties_yaml_path
    full_yaml_path('common_properties')
  end




end
