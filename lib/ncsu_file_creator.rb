class NcsuFileCreator

  def initialize
    @results = []
    @http_client = HTTPClient.new
  end

  def create
    # get the first page of results to find total_pages
    response = get_technician_results_for_page
    total_pages = response['response']['pages']['total_pages']

    # Yes, there's a duplicate request for the first page here, but this is a bit
    # simpler.
    # FIXME: total_pages
    1.times do |page|
      response = get_technician_results_for_page(page: page+1)
      puts page + 1
      response['response']['docs'].each do |doc|
        new_doc = {resource: doc['id'], images: doc['jp2_filenames_sms']}
        @results << new_doc
      end
    end
    save_results
  end

  private

  def save_results
    filepath = File.join Rails.root, 'tmp', 'ncsu_source_file.json'
    File.open(filepath, 'w') do |fh|
      fh.puts JSON.pretty_generate(@results)
    end
  end

  # Make the request to Sal for the results for the page
  def get_technician_results_for_page(page: 1)
    # FIXME: &q=technician-v9n22-1929-03-09
    url_extra = ''
    url_extra = "&q=april+1&f[resource_decade_facet][]=1980s"
    url = "http://d.lib.ncsu.edu/collections/catalog.json?f[ispartof_facet][]=Technician&per_page=5&page=#{page}#{url_extra}"
    response = @http_client.get url
    json = response.body
    JSON.parse json
  end

end
