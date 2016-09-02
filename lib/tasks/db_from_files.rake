namespace :iiifsi do
  # TODO: this is possibly a temporary script
  desc 'seed the database with information from the files on the filesystem'
  task :db_from_files => :environment do
    directory_glob = File.join Rails.configuration.iiifsi['ocr_directory'], '*/*'
    Dir.glob(directory_glob).each do |directory|
      # This only works in the case when images have an underscore and resources don't
      basename = File.basename directory
      # puts basename
      txt = File.join directory, basename + '.txt'
      hocr = File.join directory, basename + '.hocr'
      json = File.join directory, basename + '.json'
      pdf = File.join directory, basename + '.pdf'

      # Create the resource if it doesn't exist
      resource_identifier = basename.split('_').first
      resource = Resource.find_or_create_by(identifier: resource_identifier)

      if directory.include?('_') # image
        image = Image.find_or_create_by(identifier: basename)
        image.resource = resource

        # Some pages may have no text found at all but do have hocr
        if !image.txt && File.exist?(txt)
          image.txt = File.mtime(txt)
        end
        # Check for hocr & json
        if !image.hocr && File.size?(hocr)
          image.hocr = File.mtime(hocr)
        end
        if !image.json && File.size?(json)
          image.json = File.mtime(json)
        end
        image.save

      else # we have a resource
        # We would expect at least one page to have text
        if !resource.txt && File.size?(txt)
          resource.txt = File.mtime(txt)
        end
        # Check for PDF
        if !resource.pdf && File.size?(pdf)
          resource.pdf = File.mtime(pdf)
        end
        resource.save
      end

    end

  end
end
