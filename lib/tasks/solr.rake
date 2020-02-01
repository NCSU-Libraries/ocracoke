namespace :ocracoke do
  namespace :solr do

    desc 'load solr config'
    task load_config: :environment do |t|
      scl = SolrConfigLoader.new
      scl.load_all
    end

    desc 'commit solr'
    task commit: :environment do |t|
      solr = RSolr.connect url: Rails.configuration.ocracoke['solr_url']
      puts solr.commit
    end

    desc 'optimize solr (also builds suggester)'
    task optimize: :environment do |t|
      solr = RSolr.connect url: Rails.configuration.ocracoke['solr_url']
      puts solr.optimize
    end

    desc 'reindex all the images into solr'
    task reindex: :environment do |t|
      Image.all.each {|image| image.queue_index_job }
    end

    desc 'reindex specific resource'
    task :reindex_resource, [:resource] => :environment do |t, args|
      resource_identifier = args[:resource]
      resource = Resource.find_by_identifier resource_identifier
      resource.images.each do |image|
        image.queue_index_job
      end
    end

    desc 'build solr suggester'
    task build_suggester: :environment do |t|
      solr = RSolr.connect url: Rails.configuration.ocracoke['solr_url']
      response = solr.get('suggest', params: {'suggest.build' => true})
      puts response
    end

  end
end
