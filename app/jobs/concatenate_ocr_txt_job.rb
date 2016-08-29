class ConcatenateOcrTxtJob < ApplicationJob
  queue_as :concatenate_txt

  def perform(resource, images)
    puts "ConcatenateOcrJob: #{resource}"
    concatenator = OcrTxtConcatenator.new(resource, images)
    if concatenator.concatenated_ocr_txt_exists? && !ENV['REDO_OCR']
      puts "Concatenated OCR already exists for #{resource}"
    elsif concatenator.preconditions_met?
      puts "Doing ConcatenateOcrJob: #{resource}"
      concatenator.concatenate
      puts "Done ConcatenateOcrJob: #{resource}"
      # TODO: Ping another service to let it know it is complete
    else
      # Sometimes files haven't been processed or finished writing yet so we
      # just delay this for a time until it can be added back into its queue.
      puts "ConcatenateOcrJob: Preconditions not met #{resource}"
      ConcatenateOcrTxtJob.set(wait: 10.minutes).perform_later resource, images
    end
  end

end
