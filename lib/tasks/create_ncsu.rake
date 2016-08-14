namespace :iiifsi do
  desc "Create file of resource & image identifiers for use by create_ocr rake task"
  task :create_ncsu => :environment do
    creator = NcsuFileCreator.new
    creator.create
  end
end
