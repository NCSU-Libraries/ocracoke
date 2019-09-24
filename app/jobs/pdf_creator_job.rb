class PdfCreatorJob < ApplicationJob
  queue_as :pdf

  def perform(resource_id, images, percentage=50, tries=0)
    puts "PdfCreatorJob: #{resource_id}"
    pc = PdfCreator.new(resource_id, images, percentage)
    if pc.pdf_exists? && !ENV['REDO_OCR']
      puts "PDF already exists for #{resource_id}"
    elsif pc.preconditions_met?
      puts "Doing PdfCreatorJob: #{resource_id}"
      pc.create
      if pc.pdf_exists?
        puts "Done PdfCreatorJob: #{resource_id}"
        # TODO: Ping another service to let it know it is complete
        resource = Resource.find_by_identifier resource_id
        if resource && resource.callback?
          NotificationJob.perform_later resource
        end
      else
        puts "Failed PdfCreatorJob #{resource_id}"
        if tries < 6
          tries += 1
          PdfCreatorJob.set(wait: 10.minutes).perform_later resource_id, images, percentage, tries
        else
          raise "Failed PdfCreatorJob #{resource_id}"
        end
      end
    else
      # Sometimes files haven't been processed or finished writing yet so we
      # just delay this for a time until it can be added back into its queue.
      puts "PdfCreatorJob: Preconditions not met #{resource_id}"
      PdfCreatorJob.set(wait: 5.minutes).perform_later resource_id, images, percentage
    end
  end

end
