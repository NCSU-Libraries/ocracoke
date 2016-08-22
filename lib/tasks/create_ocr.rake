namespace :iiifsi do
  desc "Create OCR from a file of resource and image identifiers"
  task :create_ocr, [:resources_file] => :environment do |t, args|
    # Script that queries Sal for all Technician newspapers and
    # creates OCR for each page and then combined resources for
    # each resource.

    resources_file = args[:resources_file]

    lock_file_name = '/tmp/iiifsi_create_ocr.lock'

    # If the lock file does not exist we create it.
    unless File.exist?(lock_file_name)
      FileUtils.touch(lock_file_name)
    end

    # Unless we get a lock on the lockfile we exit immediately.
    # We keep a file handle open so that we retain the lock the whole time.
    flock_file = File.open(lock_file_name, 'w')
    unless flock_file.flock(File::LOCK_NB|File::LOCK_EX)
      puts "Can't get lock so exiting! No OCR processed."
      exit
    end

    # Set up the temporary directory
    temp_directory = File.join Dir.tmpdir, 'create_ocr'
    unless File.exist? temp_directory
      FileUtils.mkdir temp_directory
    end

    # chanage to directory to put tesseract outputs
    # Dir.chdir temp_directory

    # Clear out temp_directory in case anything is in it
    dir_glob = File.join temp_directory, '*'
    Dir.glob(dir_glob).each do |file|
      FileUtils.rm file
    end

    # read in the file of resources
    resources_file_json = File.read resources_file
    resource_documents = JSON.parse resources_file_json

    # sort by resource identifier
    resource_documents = resource_documents.sort_by{|doc| doc['resource']}

    # iterate over each resource
    resource_documents.each do |resource_document|
      # Process OCR for each of the image identifiers
      resource_document['images'].each do |image_identifier|
        puts image_identifier
        ocr_creator = OcrCreator.new(image_identifier)
        if ocr_creator.ocr_exists?
          puts "OCR already exists for #{image_identifier}"
          next
        else
          ocr_creator.process
        end
      end

      # TODO: concatenate the individual pages of the resource into
      #       combined files
      # TODO: skip this step if the resource identifier is the same as
      #       the single image identifier
      concatenator = OcrConcatenator.new(resource_document['resource'], resource_document['images'])
      if concatenator.ocr_exists?
        puts "Concatenated OCR already exists for #{resource_document['resource']}"
      else
        puts "Creating concatenated PDF for #{resource_document['resource']}"
        concatenator.concatenate
      end
      puts
    end

    # unlock the file
    flock_file.flock(File::LOCK_UN)
  end

  desc "Create OCR from a single image identifier"
  task :create_one_ocr, [:identifier] => :environment do |t, args|
    ocr_creator = OcrCreator.new(args[:identifier])
    ocr_creator.process
  end

end
