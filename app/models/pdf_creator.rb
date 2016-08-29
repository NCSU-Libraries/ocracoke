class PdfCreator

  include DirectoryFileHelpers

  def initialize(resource, images, percentage=50)
    @resource = resource
    @images = images
    # TODO: instead of just doing this by percentage there could be more
    # involved logic for how to determine how much to scale the image down
    # that is appropriate for the use.
    @percentage = percentage.to_i
    @temp_directory = File.join(Dir.tmpdir, 'create_pdf')
    @temp_directory_resource = File.join(@temp_directory, @resource)
    FileUtils.mkdir_p @temp_directory_resource
  end

  def preconditions_met?
    @images.all? do |image|
      hocr_already_exists?(image)
    end
  end

  def create
    download_all_jpgs
    resize_all_hocr
    create_resource_hocr
    clean_up
  end

  def download_all_jpgs
    http_client = HTTPClient.new
    http_client.receive_timeout = 240
    # FIXME: This should be verified!!!
    http_client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE

    # TODO: currently this depends on the image server implementing sizeByPct
    @images.each do |image|
      url = IiifUrl.from_params url_params(image)
      puts "PdfCreator downloading #{url}"
      response = http_client.get url
      jpg_tempfile = tempfile_jpg_path(image)
      File.open(jpg_tempfile, 'w') do |fh|
        fh.binmode
        fh.puts response.body
      end
    end
  end

  def resize_all_hocr
    @images.each do |image|
      puts "PdfCreator hOCR resize #{image}"
      hr = HocrResizer.new final_hocr_filepath(image)
      hr.resize @percentage
      hr.save outfile_hocr_path(image)
    end
  end

  def create_resource_hocr
    # TODO: change temporary_directory_for_identifier(@resource) to @temp_directory_resource
    result = system("hocr-pdf #{temporary_directory_for_identifier(@resource)} > #{final_pdf_filepath(@resource)}")
    if result
      puts "hocr-pdf done for #{@resource}"
    else
      puts "hocr-pdf failed for #{@resource}"
      # `convert #{temporary_filepath(@identifier, '.jpg')} #{temporary_filepath(@identifier, '.pdf')}`
    end
  end

  def pdf_exists?
    pdf_already_exists?(@resource)
  end

  def clean_up
    FileUtils.rm_rf @temp_directory_resource
  end

  private

  def url_params(image)
    {
      identifier: image,
      region: 'full',
      size: "pct:#{@percentage}",
      rotation: 0,
      quality: 'default',
      format: 'jpg'
    }
  end

  def outfile_path(image, extension)
    File.join temporary_directory_for_identifier(@resource), image + extension
  end

  def outfile_hocr_path(image)
    outfile_path image, '.hocr'
  end

  def tempfile_jpg_path(image)
    outfile_path image, '.jpg'
  end

end
