class OcrCreator
  def initialize(identifier:, temp_directory:)
    @identifier = identifier
    @temp_directory = temp_directory
  end

  def process
    # create tempfile for image
    request_file_format = 'jpg'
    tmp_download_image = Tempfile.new([@identifier, ".#{request_file_format}"])
    tmp_download_image.binmode
    # IIIF URL
    url = IiifUrl.from_params identifier: @identifier, format: request_file_format
    # get image via IIIF with httpclient
    http_client = HTTPClient.new
    response = http_client.get url
    # write image to tempfile
    tmp_download_image.write response.body

    # create outputs (txt, hOCR, PDF) with tesseract.
    # Look under /usr/share/tesseract/tessdata/configs/ to see hocr and pdf values.
    # Do not create the PDF here. Instead just take the hOCR output and
    # use a lower resolution (more compressed) version of the JPG image of the same
    # dimensions to combine the hOCR with the JPG into a PDF of reasonable size.
    `tesseract #{tmp_download_image.path} #{@identifier} -l eng hocr`

    # create directory to put final outputs
    tesseract_output_directory = directory_for_identifier
    FileUtils.mkdir_p tesseract_output_directory

    # move the txt from tesseract to final location
    FileUtils.mv temporary_filepath('.txt'), final_txt_filepath

    # Create a downsampled smaller version of the JPG
    `convert -density 150 -quality 20 #{tmp_download_image.path} #{temporary_filepath('.jpg')}`

    # create the PDF with hocr-pdf
    # FIXME: sometimes hocr-pdf fails so no PDF gets created.
    begin
      `hocr-pdf #{@temp_directory} > #{temporary_filepath('.pdf')}`
    rescue
    end

    # move the hOCR to the final location
    FileUtils.mv temporary_filepath('.hocr'), final_hocr_filepath

    # move the PDF to final location if it exists
    if File.exist?(temporary_filepath('.pdf')) && File.size?(temporary_filepath('.pdf'))
      FileUtils.mv temporary_filepath('.pdf'), final_pdf_filepath
    end

    # remove the downsampled JPG
    FileUtils.rm temporary_filepath('.jpg')

    # Do a check that the files were properly created
    if ocr_already_exists?
      # extract words and boundaries from hOCR into a JSON file
      create_word_boundary_json
      # Set permissions
      FileUtils.chmod_R('ug=rwX,o=rX', directory_for_first_two)
    else
      # remove them if they don't exist
      FileUtils.rm_rf directory_for_identifier
    end

    # remove the temporary file
    tmp_download_image.unlink
  end

  def create_word_boundary_json
    # final_json_file_filepath(identifier)
    doc = File.open(final_hocr_filepath) { |f| Nokogiri::HTML(f) }
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
    File.open(final_json_file_filepath, 'w') do |fh|
      fh.puts json.to_json
    end
  end

  def directory_for_first_two
    first_two_of_identifier = @identifier.slice(0, 2)
    File.join Rails.configuration.iiifsi['ocr_directory'], first_two_of_identifier
  end

  def directory_for_identifier
    File.join directory_for_first_two, @identifier
  end

  def final_output_base_filepath
    File.join directory_for_identifier, @identifier
  end
  def final_txt_filepath
    final_output_base_filepath + '.txt'
  end
  def final_hocr_filepath
    final_output_base_filepath + '.hocr'
  end
  def final_pdf_filepath
    final_output_base_filepath + '.pdf'
  end
  def final_json_file_filepath
    final_output_base_filepath + '.json'
  end

  # Temporary filepaths
  def temporary_filepath(extension)
    File.join @temp_directory, @identifier + extension
  end

  # Based on a identifier determine if all the OCR files already exist
  def ocr_already_exists?
    File.size?(final_txt_filepath) && File.size?(final_hocr_filepath)
    # FIXME: && File.size?(final_pdf_filepath(identifier))
  end

end
