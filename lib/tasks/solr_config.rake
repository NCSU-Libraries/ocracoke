namespace :ocracoke do
  namespace :solr do

    task load_config: :environment do |t|
      scl = SolrConfigLoader.new
      scl.load_all
    end

  end
end
