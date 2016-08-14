class OcrCreator

  include DirectoryFileHelpers

  def initialize(identifier:, temp_directory:)
    @identifier = identifier
    @temp_directory = temp_directory
    Dir.chdir temp_directory
    @http_client = HTTPClient.new
  end

  def process
    # create tempfile for image
    request_file_format = 'jpg'
    tmp_download_image = Tempfile.new([@identifier, ".#{request_file_format}"])
    tmp_download_image.binmode
    # IIIF URL
    url = IiifUrl.from_params identifier: @identifier, format: request_file_format
    # get image via IIIF with httpclient
    response = @http_client.get url
    # write image to tempfile
    tmp_download_image.write response.body

    # create outputs (txt, hOCR, PDF) with tesseract.
    # Look under /usr/share/tesseract/tessdata/configs/ to see hocr and pdf values.
    # Do not create the PDF here. Instead just take the hOCR output and
    # use a lower resolution (more compressed) version of the JPG image of the same
    # dimensions to combine the hOCR with the JPG into a PDF of reasonable size.
    `tesseract #{tmp_download_image.path} #{@identifier} -l eng hocr`

    # create directory to put final outputs
    FileUtils.mkdir_p directory_for_identifier(@identifier)

    # move the txt from tesseract to final location
    FileUtils.mv temporary_filepath(@identifier, '.txt'), final_txt_filepath(@identifier)

    # Create a downsampled smaller version of the JPG
    `convert -density 150 -quality 20 #{tmp_download_image.path} #{temporary_filepath(@identifier, '.jpg')}`

    # create the PDF with hocr-pdf
    # FIXME: sometimes hocr-pdf fails so no PDF gets created.
    begin
      `hocr-pdf #{@temp_directory} > #{temporary_filepath(@identifier, '.pdf')}`
    rescue
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
      # remove them if they don't exist
      FileUtils.rm_rf directory_for_identifier(@identifier)
    end

    # remove the temporary file
    tmp_download_image.unlink
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
