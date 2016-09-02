namespace :iiifsi do
  desc 'queue a resource and images for OCR from an NCSU resource identifier'
  task :queue_from_ncsu_id, [:id] => :environment do |t, args|
    base_url = "https://d.lib.ncsu.edu/collections"
    url = File.join base_url, "/catalog/#{args[:id]}.json"
    http = HTTPClient.new
    response = http.get url
    if response.status == 200
      json = response.body
      result = JSON.parse json
      images = result['images']
      if !images.blank?
        ResourceOcrJob.perform_later args[:id], images
      else
        puts "No images."
      end
    else
      puts "Error!"
    end
  end
end
