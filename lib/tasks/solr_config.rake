namespace :ocracoke do
  namespace :solr do

    desc 'load solr config'
    task load_config: :environment do |t|
      scl = SolrConfigLoader.new
      scl.load_all
    end

    desc 'build solr suggester'
    task build_suggester: :environment do |t|
      solr = RSolr.connect url: Rails.configuration.ocracoke['solr_url']
      response = solr.get('suggest', params: {'suggest.build' => true})
      puts response
    end

  end
end
