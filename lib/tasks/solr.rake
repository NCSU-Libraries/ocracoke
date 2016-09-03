namespace :iiifsi do
  namespace :solr do
    desc 'commit solr'
    task commit: :environment do |t|
      solr = RSolr.connect url: Rails.configuration.iiifsi['solr_url']
      puts solr.commit
    end

    desc 'restart solr'
    task restart: :environment do |t|
      unload_url = "http://localhost:8983/solr/admin/cores?core=iiifsi&action=UNLOAD"
      create_url = "http://localhost:8983/solr/admin/cores?name=iiifsi&action=CREATE"
      http_client = HTTPClient.new
      http_client.receive_timeout = 240
      unload_response = http_client.get unload_url
      puts unload_response.body
      puts
      create_response = http_client.get create_url
      puts create_response.body
    end

  end
end
