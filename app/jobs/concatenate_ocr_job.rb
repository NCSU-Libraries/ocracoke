class ConcatenateOcrJob < ApplicationJob
  queue_as :concatenate

  def perform(resource, images)
    puts "ConcatenateOcrJob: #{resource}"
    concatenator = OcrConcatenator.new(resource, images)
    if concatenator.concatenated_ocr_exists? && !ENV['REDO_OCR']
      puts "Concatenated OCR already exists for #{resource}"
    elsif concatenator.preconditions_met?
      concatenator.concatenate
      # TODO: Ping another service to let it know it is complete
    else
      puts "ConcatenateOcrJob: Preconditions not met #{resource}"
      ConcatenateOcrJob.set(wait: 1.minute).perform_later resource, images
    end
  end

end
