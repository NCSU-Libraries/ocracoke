class OcrConcatenator

  include DirectoryFileHelpers

  def initialize(resource_document:)
    @doc = resource_document
    @resource = @doc['resource']
  end

  def concatenate
    # Create directory for files at resource level
    unless File.exist? directory_for_identifier(@resource)
      FileUtils.mkdir directory_for_identifier(@resource)
    end

    concatenate_pdf
    concatenate_txt
    # TODO: concatenate hOCR?
    # TODO: set proper permissions on combined files
  end

  def concatenate_pdf
    # Use pdunite to join all the PDFs into one
    pdfunite = "pdfunite "
    pdf_pages = []
    @doc['images'].each do |identifier|
      # If the file exists then add it to the pdfunite command
      if File.exist? final_pdf_filepath(identifier)
        pdf_pages << final_pdf_filepath(identifier) + ' '
      end
    end
    # Add onto the end the path to the final resource PDF
    pdfunite << "#{pdf_pages.join(' ')} #{final_pdf_filepath(@resource)} "
    # Only try to create the combined PDF if all the pages have a PDF
    if pdf_pages.length == @doc['images'].length
      `#{pdfunite}`
    else
      puts "Some pages do not have a PDF. Skipping creation of combined PDF."
    end
  end

  # TODO: Maybe there's a better way to do this without having to read in each text file?
  def concatenate_txt
    File.open final_txt_filepath(@resource), 'w' do |fh|
      @doc['images'].each do |identifier|
        fh.puts File.read(final_txt_filepath(identifier))
        fh.puts "\n\n\n"
      end
    end
  end

  def ocr_exists?
    pdf_exists?(id) && File.exist?(final_txt_filepath(id))
  end

end
