namespace :ocracoke do
  desc "Index all the OCR into Solr"
  task :index_ocr, [:resources_file] => :environment do |t, args|
    include DirectoryFileHelpers

    solr = RSolr.connect url: Rails.configuration.ocracoke['solr_url']

    # TODO: Allow for skipping over errors instead of failing on them
    begin
      resources_file = args[:resources_file]

      resources_file_json = File.read resources_file
      resource_documents = JSON.parse resources_file_json

      # sort by resource identifier
      resource_documents = resource_documents.sort_by{|doc| doc['resource']}

      # iterate over each resource
      resource_documents.each do |resource_document|
        resource_document['images'].each do |image_identifier|
          ocr_indexer = OcrIndexer.new(resource: resource_document['resource'], image: image_identifier)
          ocr_indexer.index
        end
      end
      commit = solr.commit
      puts "commit: #{commit}"
    rescue => e
      puts "ERROR!"
      puts e
      puts e.backtrace
      commit = solr.commit
      puts "commit: #{commit}"
      puts "ERROR!"
    end

  end
end
