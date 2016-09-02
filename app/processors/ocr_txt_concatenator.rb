class OcrTxtConcatenator

  include DirectoryFileHelpers

  def initialize(resource, images)
    @resource = resource
    @images = images
  end

  # All of the text files and PDF files must be present before we
  # can do this. So this is the check we can use.
  def preconditions_met?
    @images.all? do |image|
      txt_already_exists?(image)
    end
  end

  def concatenate
    # Create directory for files at resource level
    unless File.exist? directory_for_identifier(@resource)
      FileUtils.mkdir directory_for_identifier(@resource)
    end

    File.open final_txt_filepath(@resource), 'w' do |fh|
      @images.each do |identifier|
        fh.puts File.read(final_txt_filepath(identifier))
        fh.puts "\n\n\n"
      end
    end
  end

  def concatenated_ocr_txt_exists?
    txt_already_exists?(@resource)
  end

end

__END__

def concatenate_pdf
  # Use pdunite to join all the PDFs into one
  pdfunite = "pdfunite "
  pdf_pages = []
  @images.each do |identifier|
    # If the file exists then add it to the pdfunite command
    if File.exist? final_pdf_filepath(identifier)
      pdf_pages << final_pdf_filepath(identifier) + ' '
    end
  end
  # Add onto the end the path to the final resource PDF
  pdfunite << "#{pdf_pages.join(' ')} #{final_pdf_filepath(@resource)} "
  # Only try to create the combined PDF if all the pages have a PDF
  if pdf_pages.length == @images.length
    `#{pdfunite}`
  else
    puts "Some pages do not have a PDF. Skipping creation of combined PDF."
  end
end
