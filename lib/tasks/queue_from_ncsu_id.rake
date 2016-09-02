namespace :iiifsi do
  desc 'queue a resource and images for OCR from an NCSU resource identifier'
  task :queue_from_ncsu_id, [:id] => :environment do |t, args|
    NcsuIdQueuer.queue(args[:id])
  end
end
