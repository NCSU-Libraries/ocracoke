namespace :iiifsi do
  namespace :solr do
    desc 'commit solr'
    task commit: :environment do |t|
      solr = RSolr.connect url: Rails.configuration.iiifsi['solr_url']
      puts solr.commit
    end

    # This is about the worst way to do this, but RELOAD currently does not work
    # with the AnalyzingInfixSuggester we use for suggestions.
    # https://issues.apache.org/jira/browse/SOLR-6246
    # Instead we take Solr offline for a moment and recreate it. Unloading
    # leaves everything just as it was so that
    desc 'restart solr'
    task restart: :environment do |t|
      unload_url = "http://localhost:8983/solr/admin/cores?core=iiifsi&action=UNLOAD"
      create_url = "http://localhost:8983/solr/admin/cores?name=iiifsi&action=CREATE"
      status_url = "http://localhost:8983/solr/admin/cores?core=iiifsi&action=STATUS"
      http_client = HTTPClient.new
      http_client.receive_timeout = 240
      unload_response = http_client.get unload_url
      puts unload_response.body
      puts
      create_response = http_client.get create_url
      puts create_response.body
      puts
      status_response = http_client.get status_url
      status_xml = status_response.body
      status_doc = Nokogiri::XML(status_xml)
      puts status_doc.human
    end

  end
end
