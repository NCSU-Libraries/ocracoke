namespace :iiifsi do
  # TODO: this is possibly a temporary script
  desc 'check on presence of required OCR files'
  task :check_ocr => :environment do
    errors = []
    directory_glob = File.join Rails.configuration.iiifsi['ocr_directory'], '*/*'
    Dir.glob(directory_glob).each do |directory|
      # This only works in the case when images have an underscore and resources don't
      basename = File.basename directory
      txt = File.join directory, basename + '.txt'
      hocr = File.join directory, basename + '.hocr'
      json = File.join directory, basename + '.json'
      pdf = File.join directory, basename + '.pdf'

      # For both images and resources we check for txt
      if !File.size?(txt)
        errors << txt
        puts "txt: #{basename}"
      end

      if directory.include?('_') # image
        # Check for hocr & json
        if !File.size?(hocr)
          errors << hocr
          puts "hocr: #{basename}"
        end
        if !File.size?(json)
          errors << json
          puts "json: #{basename}"
        end

        # Remove any PDFs while we're at it
        if File.exist?(pdf)
          puts "Removing PDF: #{basename}"
          FileUtils.rm pdf
        end

      else # we have a resource
        # Check for PDF
        if !File.size?(pdf)
          errors << pdf
          puts "pdf: #{basename}"
        end
      end

    end

    date = DateTime.now.strftime('%Y-%m-%d-%H-%M-%S')
    error_file = File.join Rails.root, 'tmp', "empty-file-errors-#{date}.log"
    File.open(error_file, 'w') do |fh|
      fh.puts errors
    end
  end
end
