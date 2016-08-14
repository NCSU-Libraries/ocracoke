namespace :iiifsi do
  desc "Index all the OCR into Solr"
  task :index_ocr, [:resources_file] => :environment do |t, args|
    include DirectoryFileHelpers

    solr = RSolr.connect url: Rails.configuration.iiifsi['solr_url']

    resources_file = args[:resources_file]

    resources_file_json = File.read resources_file
    resource_documents = JSON.parse resources_file_json
    # iterate over each resource
    resource_documents.each do |resource_document|
      resource_document['images'].each do |image_identifier|
        text = File.read final_txt_filepath(image_identifier)
        page = {
          id: image_identifier,
          resource: resource_document['resource'],
          txt: text
        }
        add = solr.add page
        puts "add #{image_identifier}: #{add}"
      end
    end
    commit = solr.commit
    puts "commit: #{commit}"
  end
end
