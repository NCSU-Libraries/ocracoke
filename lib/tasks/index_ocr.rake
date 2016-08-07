namespace :iiifsi do
  task :index_ocr => :environment do
    solr = RSolr.connect url: 'http://localhost:8983/solr/iiifsi'
    Dir.glob("/access-images/ocr/te/*_*").each do |directory_path|
      puts directory_path
      id = directory_path.split('/').last
      filename = id.split('_').first
      text_file = File.join directory_path, id + ".txt"
      text = File.read text_file
      page = {
        id: id,
        filename: filename,
        txt: text
      }
      puts page
      solr.add page
    end
    solr.commit
  end
end
