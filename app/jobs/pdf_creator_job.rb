class PdfCreatorJob < ApplicationJob
  queue_as :pdf

  def perform(resource, images, percentage=50)
    puts "PdfCreatorJob: #{resource}"
    pc = PdfCreator.new(resource, images, percentage)
    if pc.pdf_exists? && !ENV['REDO_OCR']
      puts "PDF already exists for #{resource}"
    elsif pc.preconditions_met?
      puts "Doing PdfCreatorJob: #{resource}"
      pc.create
      if pc.pdf_exists?
        puts "Done PdfCreatorJob: #{resource}"
        # TODO: Ping another service to let it know it is complete
      else
        puts "Failed PdfCreatorJob #{resource}"
        raise "Failed PdfCreatorJob #{resource}"
        # PdfCreatorJob.set(wait: 10.minutes).perform_later resource, images, percentage
      end
    else
      # Sometimes files haven't been processed or finished writing yet so we
      # just delay this for a time until it can be added back into its queue.
      puts "PdfCreatorJob: Preconditions not met #{resource}"
      PdfCreatorJob.set(wait: 5.minutes).perform_later resource, images, percentage
    end
  end

end
