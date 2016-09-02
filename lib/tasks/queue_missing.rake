namespace :iiifsi do
  desc 'interrogate the database for missing pieces and queue needed jobs'
  task queue_missing: :environment do
    # TODO
    puts "not yet implemented"
    exit
    # missing PDFs
    resources = Resource.where(pdf: nil)
  end
end
