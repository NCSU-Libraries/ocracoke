namespace :iiifsi do
  # TODO: this is possibly a temporary script
  desc 'check on presence of required OCR files'
  task :check_ocr => :environment do
    errors = []
    directory_glob = File.join Rails.configuration.iiifsi['ocr_directory'], '*/*'
    Dir.glob(directory_glob).each do |directory|
      # This only works in the case when images have an underscore and resources don't
      basename = File.basename directory
      # puts basename
      txt = File.join directory, basename + '.txt'
      hocr = File.join directory, basename + '.hocr'
      json = File.join directory, basename + '.json'
      pdf = File.join directory, basename + '.pdf'

      directory_errors = []

      if directory.include?('_') # image
        # Some pages may have no text found at all but do have hocr
        if !File.exist?(txt)
          directory_errors << 'txt'
        end
        # Check for hocr & json
        if !File.size?(hocr)
          directory_errors << 'hocr'
        end
        if !File.size?(json)
          directory_errors << 'json'
        end
        # delete any PDFs for images while we're at it
        if File.exist?(pdf)
          FileUtils.rm pdf
        end

      else # we have a resource
        # We would expect at least one page to have text
        if !File.size?(txt)
          directory_errors << 'txt'
        end
        # Check for PDF
        if !File.size?(pdf)
          directory_errors << 'pdf'
        end
      end

      if !directory_errors.blank?
        puts "#{basename}: #{directory_errors}"
        errors << {basename => directory_errors}
      end

    end

    date = DateTime.now.strftime('%Y-%m-%d-%H-%M-%S')
    error_file = File.join Rails.root, 'tmp', "empty-file-errors-#{date}.log"
    File.open(error_file, 'w') do |fh|
      fh.puts errors.to_json
    end
  end
end
