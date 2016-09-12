namespace :ocracoke do
  desc 'queue resources from a query of NCSU digital collections'
  task :queue_from_ncsu_query, [:query] => :environment do |t, args|
    NcsuQueryQueuer.new(args[:query]).queue
  end
end
