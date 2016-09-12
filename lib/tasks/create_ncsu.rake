namespace :ocracoke do
  desc "Create file of resource & image identifiers for use by create_ocr rake task"
  task :create_ncsu, [:outfile, :url] => :environment do |t, args|
    creator = NcsuFileCreator.new(outfile: args[:outfile], url: args[:url])
    creator.create
  end
end
