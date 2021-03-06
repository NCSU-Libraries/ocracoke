class OcrCreator

  include DirectoryFileHelpers

  def initialize(identifier)
    @identifier = identifier
    @temp_directory = File.join(Dir.tmpdir, 'create_ocr')
    FileUtils.mkdir_p @temp_directory
    @http_client = HTTPClient.new
    @http_client.receive_timeout = 240
    # FIXME: This should be verified!!!
    # @http_client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  def process
    time = Benchmark.measure do
      # Create temporary directory for just this image. We do this so that
      # hocr-pdf or other tools are only dealing with a single image and
      # never act on more than one image. We need to do this before
      # any call here to temporary_filepath.
      temporary_directory_for_id = temporary_directory_for_identifier(@identifier)
      FileUtils.mkdir_p temporary_directory_for_id
      Dir.chdir temporary_directory_for_id

      # create tempfile for image
      request_file_format = 'jpg'
      tmp_download_image = Tempfile.new([@identifier, ".#{request_file_format}"], temporary_directory_for_id)
      # create IIIF URL
      url = IiifUrl.from_params identifier: @identifier, format: request_file_format
      # turn on binmode for tempfile so we can write to it
      tmp_download_image.binmode
      # get image via IIIF with httpclient
      puts "Getting #{@identifier} #{url}"
      response = @http_client.get url, follow_redirect: true
      # write image to tempfile
      tmp_download_image.write response.body

      # create outputs (txt, hOCR) with tesseract.
      # Look under /usr/share/tesseract/tessdata/configs/ to see hocr values.
      puts "Tesseract starting for #{@identifier}"
      tesseract_cmd = "nice tesseract #{tmp_download_image.path} #{@identifier} -l eng hocr"
      puts tesseract_cmd
      `#{tesseract_cmd}`
      puts "Tesseract complete for #{@identifier}"

      # Remove the temporary file as we don't need it anymore.
      tmp_download_image.unlink

      # create directory to put final outputs
      FileUtils.mkdir_p directory_for_identifier(@identifier)

      # move the txt from tesseract to final location
      FileUtils.mv temporary_filepath(@identifier, '.txt'), final_txt_filepath(@identifier)

      # move the hOCR to the final location
      FileUtils.mv temporary_filepath(@identifier, '.hocr'), final_hocr_filepath(@identifier)

      # Set permissions
      FileUtils.chmod_R('ug=rwX,o=rX', directory_for_identifier(@identifier))

      image = Image.find_by(identifier: @identifier)
      if hocr_already_exists?(@identifier)
        image.hocr = DateTime.now
        if txt_already_exists?(@identifier)
          image.txt = DateTime.now
        else
          FileUtils.rm final_txt_filepath(@identifier)
        end
      else
        # If the hocr doesn't exist then we get rid of the txt too
        FileUtils.rm final_hocr_filepath(@identifier)
        FileUtils.rm final_txt_filepath(@identifier)
      end
      image.save

      # clean up the temporary directory used for processing a single image
      FileUtils.rm_rf temporary_directory_for_id
    end
    puts "OCRTime #{@identifier} #{time}"
  end

  def ocr_exists?
    ocr_already_exists?(@identifier)
  end

end
