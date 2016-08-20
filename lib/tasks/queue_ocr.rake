namespace :iiifsi do
  desc "Queue OCR jobs from a file of resource and image identifiers"
  task :queue_ocr, [:resources_file] => :environment do |t, args|

    temp_directory = File.join Dir.tmpdir, 'create_ocr'
    unless File.exist? temp_directory
      FileUtils.mkdir temp_directory
    end

    resources_file = args[:resources_file]
    resources_file_json = File.read resources_file
    resource_documents = JSON.parse resources_file_json
    resource_documents = resource_documents.sort_by{|doc| doc['resource']}
    resource_documents.each do |resource_document|
      resource = resource_document['resource']
      images = resource_document['images']
      ResourceOcrJob.perform_later resource, images
      exit
    end
  end
end
