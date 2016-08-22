class OcrCreator

  include DirectoryFileHelpers

  def initialize(identifier)
    @identifier = identifier
    @temp_directory = File.join(Dir.tmpdir, 'create_ocr')
    Dir.chdir @temp_directory
    @http_client = HTTPClient.new
    @http_client.receive_timeout = 240
  end

  def process
    time = Benchmark.measure do
      # create tempfile for image
      request_file_format = 'jpg'
      tmp_download_image = Tempfile.new([@identifier, ".#{request_file_format}"])
      # IIIF URL
      url = IiifUrl.from_params identifier: @identifier, format: request_file_format

      # FIXME: this is for get rather than head requests
      if false #ENV['PROCESS_FROM_REMOTE_IIIF_SERVER']
        tmp_download_image.binmode
        # get image via IIIF with httpclient
        response = @http_client.get url
        # write image to tempfile
        tmp_download_image.write response.body
      else
        # We have access directly to this storage so we can just make a head
        # request which creates the image but then instead of downloading it via
        # HTTP we can just move it to where we expect it to be.
        # send a head request for the image
        response = @http_client.head url
        cache_file = File.join '/access-images/cache-staging/iiif', @identifier, "/full/full/0/default.jpg"
        tries = 0
        while !File.exist?(cache_file) && tries < 30
          puts "waiting for head #{@identifier} #{tries}..."
          sleep 0.5
          tries += 1
        end
        # TODO: we could do a cp here to retain the file if we wanted to.
        FileUtils.cp cache_file, tmp_download_image.path
      end

      # create outputs (txt, hOCR, PDF) with tesseract.
      # Look under /usr/share/tesseract/tessdata/configs/ to see hocr and pdf values.
      # Do not create the PDF here. Instead just take the hOCR output and
      # use a lower resolution (more compressed) version of the JPG image of the same
      # dimensions to combine the hOCR with the JPG into a PDF of reasonable size.
      `tesseract #{tmp_download_image.path} #{@identifier} -l eng hocr`

      # Create a downsampled smaller version of the JPG
      `convert -density 150 -quality 20 #{tmp_download_image.path} #{temporary_filepath(@identifier, '.jpg')}`

      # create directory to put final outputs
      FileUtils.mkdir_p directory_for_identifier(@identifier)

      # move the txt from tesseract to final location
      FileUtils.mv temporary_filepath(@identifier, '.txt'), final_txt_filepath(@identifier)

      # create the PDF with hocr-pdf
      # FIXME: sometimes hocr-pdf fails so no PDF gets created. When hocr-tools is
      #        fixed remove the rescue convert below
      result = system("hocr-pdf #{@temp_directory} > #{temporary_filepath(@identifier, '.pdf')}")
      if !result
        `convert #{temporary_filepath(@identifier, '.jpg')} #{temporary_filepath(@identifier, '.pdf')}`
      end

      # move the hOCR to the final location
      FileUtils.mv temporary_filepath(@identifier, '.hocr'), final_hocr_filepath(@identifier)

      # move the PDF to final location if it exists
      # TODO: could this be simplified by just testing size?
      if File.exist?(temporary_filepath(@identifier, '.pdf')) && File.size?(temporary_filepath(@identifier, '.pdf'))
        FileUtils.mv temporary_filepath(@identifier, '.pdf'), final_pdf_filepath(@identifier)
      end

      # remove the downsampled JPG
      FileUtils.rm temporary_filepath(@identifier, '.jpg')

      # Do a check that the files were properly created
      if ocr_already_exists?(@identifier)
        # extract words and boundaries from hOCR into a JSON file
        create_word_boundary_json
        # Set permissions
        FileUtils.chmod_R('ug=rwX,o=rX', directory_for_first_two(@identifier))
      else
        # remove the files if full OCR doesn't exist
        FileUtils.rm_rf directory_for_identifier(@identifier)
      end

      # remove the temporary file
      tmp_download_image.unlink

    end
    puts "OCR Time #{@identifier} #{time} "
  end

  # TODO: extract out OCR JSON into its own file
  def create_word_boundary_json
    # final_json_file_filepath(identifier)
    doc = File.open(final_hocr_filepath(@identifier)) { |f| Nokogiri::HTML(f) }
    json = {}
    doc.css('span.ocrx_word').each do |span|
      text = span.text
      # Filter out non-word characters
      word_match = text.match /\w+/
      next if word_match.nil?
      word = word_match[0]
      next if word.length < 3
      json[word] ||= []
      title = span['title']
      info = parse_hocr_title(title)
      # FIXME: is it possible here to turn the bounding box numbers into integers?
      json[word] << info
    end
    File.open(final_json_file_filepath(@identifier), 'w') do |fh|
      fh.puts json.to_json
    end
  end

  def ocr_exists?
    ocr_already_exists?(@identifier)
  end

  private

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

end
