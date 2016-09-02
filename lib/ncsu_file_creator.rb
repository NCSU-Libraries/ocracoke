class NcsuFileCreator

  def initialize(outfile:nil, url:nil)
    @outfile = if outfile
      outfile
    else
      File.join Rails.root, 'tmp', 'ncsu_source_file.json'
    end
    @url = if url
      url
    else
      # Just create the source file for the Technicians if no URL given
      ipo = "Nubian Message"
      "http://d.lib.ncsu.edu/collections/catalog.json?f[format][]=Text&f[ispartof_facet][]=#{ipo}"
    end
    @results = []
    @http_client = HTTPClient.new
  end

  def create
    # get the first page of results to find total_pages
    response = get_technician_results_for_page
    total_pages = response['response']['pages']['total_pages']

    # Yes, there's a duplicate request for the first page here, but this is a bit
    # simpler.
    total_pages.times do |page|
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
    File.open(@outfile, 'w') do |fh|
      fh.puts JSON.pretty_generate(@results)
    end
  end

  # Make the request to Sal for the results for the page
  def get_technician_results_for_page(page: 1)
    response = @http_client.get(@url + "&per_page=25&page=#{page}")
    json = response.body
    JSON.parse json
  end

end
