namespace :iiifsi do
  task :index_ocr => :environment do
    solr = RSolr.connect url: 'http://localhost:8983/solr/iiifsi'
    # We're only going to index the individual pages and not whole documents
    glob = File.join Rails.configuration.iiifsi['ocr_directory'], "/*/*_*"
    Dir.glob(glob).each do |directory_path|
      id = directory_path.split('/').last
      puts id
      filename = id.split('_').first
      text_file = File.join directory_path, id + ".txt"
      text = File.read text_file
      page = {
        id: id,
        filename: filename,
        txt: text
      }
      solr.add page
    end
    solr.commit
  end
end
