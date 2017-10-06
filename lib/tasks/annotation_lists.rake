namespace :ocracoke do
  desc "Queue annotation list jobs for every resource"
  task :queue_annotation_lists => :environment do
    Image.find_each do |image|
      AnnotationListJob.perform_later image.identifier
      puts image.identifier
    end
  end
end
