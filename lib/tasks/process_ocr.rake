namespace :iiifsi do
  task :process_ocr => :environment do
    # Script that queries Sal for all Technician newspapers and
    # creates OCR for each page and then combined resources for
    # each resource.

    lock_file_name = '/tmp/process_technician_ocr.lock'

    # If the lock file does not exist we create it.
    unless File.exist?(lock_file_name)
      FileUtils.touch(lock_file_name)
    end

    # Unless we get a lock on the lockfile we exit immediately.
    # We keep a file handle open so that we retain the lock the whole time.
    flock_file = File.open(lock_file_name, 'w')
    unless flock_file.flock(File::LOCK_NB|File::LOCK_EX)
      puts "Can't get lock so exiting! No OCR processed."
      exit
    end

    # set up some variables
    @http_client = HTTPClient.new
    @temp_directory = File.join Dir.tmpdir, 'process_ocr'
    unless File.exist? @temp_directory
      FileUtils.mkdir @temp_directory
    end
    # chanage to directory to put tesseract outputs
    Dir.chdir @temp_directory
    # Clear out temp_directory in case anything is in it
    dir_glob = File.join @temp_directory, '*'
    Dir.glob(dir_glob).each do |file|
      FileUtils.rm file
    end

    # Make the request to Sal for the results for the page
    def get_technician_results_for_page(page: 1)
      # FIXME: &q=technician-v9n22-1929-03-09
      url_extra = ''
      url_extra = "&q=april+1&f[resource_decade_facet][]=1980s"
      url = "http://d.lib.ncsu.edu/collections/catalog.json?f[ispartof_facet][]=Technician&per_page=10&page=#{page}#{url_extra}"
      response = @http_client.get url
      json = response.body
      JSON.parse json
    end

    def parse_hocr_title(title)
      parts = title.split(';').map(&:strip)
      info = {}
      parts.each do |part|
        sections = part.split(' ')
        sections.shift
        if /^bbox/.match(part)
          info['x0'], info['y0'], info['x1'], info['y1'] = sections
        elsif /^x_wconf/.match(part)
          info['c'] = sections.first
        end
      end
      info
    end

    # Given a doc iterate over each of the jp2s and process OCR for them
    def process_ocr_for_each_page(doc)
      doc['jp2_filenames_sms'].each do |identifier|
        puts identifier
        ocr_creator = OcrCreator.new(identifier: identifier, temp_directory: @temp_directory)
        if ocr_creator.ocr_already_exists?
          puts "OCR already exists. Skipping #{identifier}"
          next
        else
          ocr_creator.process
        end
      end
    end

    def concatenate_pdf(doc)
      # Use pdunite to join all the PDFs into one
      pdfunite = "pdfunite"
      pdf_pages = []
      doc['jp2_filenames_sms'].each do |identifier|
        # If the file exists then add it to the pdfunite command
        if File.exist? final_pdf_filepath(identifier)
          pdf_pages << final_pdf_filepath(identifier) + ' '
        end
      end
      # Add onto the end the path to the final resource PDF
      pdfunite << " #{pdf_pages.join(' ')} #{final_pdf_filepath(doc['id'])} "
      # Only try to create the combined PDF if all the pages have a PDF
      if pdf_pages.length == doc['jp2_filenames_sms'].length
        `#{pdfunite}`
      else
        puts "Some pages do not have a PDF. Skipping creation of combined PDF."
      end
    end

    def concatenate_txt(doc)
      text = ""
      doc['jp2_filenames_sms'].each do |identifier|
        text << File.read(final_txt_filepath(identifier))
      end
      File.open final_txt_filepath(doc['filename']), 'w' do |fh|
        fh.puts text
      end
    end

    # Given a doc create concatenated resources from them
    def concatenate_ocr_for_resource(doc)
      # Create directory for files at resource level
      unless File.exist? directory_for_identifier(doc["filename"])
        FileUtils.mkdir directory_for_identifier(doc["filename"])
      end

      #concatenate pdf
      concatenate_pdf(doc)

      # concatenate txt
      concatenate_txt(doc)

      # TODO: concatenate hOCR?

      # TODO: set proper permissions on combined files
    end

    # get the first page of results to find total_pages
    response = get_technician_results_for_page
    total_pages = response['response']['pages']['total_pages']

    # Yes, there's a duplicate request for the first page here, but this is a bit
    # simpler.
    total_pages
    5.times do |page|
      response = get_technician_results_for_page(page: page)
      response['response']['docs'].each do |doc|
        # A doc is a resource and can have multiple pages
        process_ocr_for_each_page(doc)
        #FIXME: concatenate_ocr_for_resource(doc)
      end
    end

    # unlock the file
    flock_file.flock(File::LOCK_UN)

  end
end
