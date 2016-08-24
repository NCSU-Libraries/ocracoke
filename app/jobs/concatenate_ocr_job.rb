class ConcatenateOcrJob < ApplicationJob
  queue_as :concatenate

  def perform(resource, images)
    puts "ConcatenateOcrJob: #{resource}"
    concatenator = OcrConcatenator.new(resource, images)
    if concatenator.concatenated_ocr_exists? && !ENV['REDO_OCR']
      puts "Concatenated OCR already exists for #{resource}"
    else
      # If the preconditions aren't met then requeue the job for later.
      if concatenator.preconditions_met?
        concatenator.concatenate
      else
        # TODO: Set a cronjob to queue the delayed jobs?
        puts "ConcatenateOcrJob: Preconditions not met #{resource}"
        raise "Preconditions not met!"
      end
      # TODO: Ping another service to let it know it is complete
    end
  end
end
