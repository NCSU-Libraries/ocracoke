module NcsuIdQueuer

  def self.queue(id)
    base_url = "https://d.lib.ncsu.edu/collections"
    url = File.join base_url, "/catalog/#{id}.json"
    http = HTTPClient.new
    response = http.get url
    if response.status == 200
      json = response.body
      result = JSON.parse json
      images = result['images']
      if !images.blank?
        ResourceOcrJob.perform_later id, images
      else
        puts "No images."
      end
    else
      puts "Error!"
    end
  end

end
