namespace :iiifsi do
  namespace :solr do
    desc 'commit solr'
    task commit: :environment do |t|
      solr = RSolr.connect url: Rails.configuration.iiifsi['solr_url']
      puts solr.commit
    end

    task reindex: :environment do |t|
      Image.all.each {|image| image.queue_index_job }
    end

  end
end
