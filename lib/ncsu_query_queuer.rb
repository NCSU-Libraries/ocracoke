class NcsuQueryQueuer
  def initialize(query)
    @query = query
    @http_client = HTTPClient.new
  end

  def queue
    # get the first page of results to find total_pages
    response = get_technician_results_for_page
    total_pages = response['response']['pages']['total_pages']

    # Yes, there's a duplicate request for the first page here, but this is a bit
    # simpler.
    total_pages.times do |page|
      response = get_technician_results_for_page(page: page+1)
      puts page + 1
      response['response']['docs'].each do |doc|
        resource = doc['id']
        images = doc['jp2_filenames_sms']
        ResourceOcrJob.perform_later resource, images
      end
    end
  end

  # Make the request to Sal for the results for the page
  def get_technician_results_for_page(page: 1)
    response = @http_client.get(@query + "&per_page=25&page=#{page}")
    json = response.body
    JSON.parse json
  end
end
