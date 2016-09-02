class OcrJob < ApplicationJob
  queue_as :ocr

  # Provide a way to redo the OCR for an item
  def perform(image, resource=nil)
    puts "OcrJob: #{image}"
    ocr_creator = OcrCreator.new(image)
    if ocr_creator.ocr_exists? && !ENV['REDO_OCR']
      puts "OCR already exists for #{image}"
    else
      ocr_creator.process
      if ocr_creator.ocr_exists?
        WordBoundariesJob.perform_later image
        if resource
          IndexOcrJob.perform_later resource, image
        end
      else
        OcrJob.set(wait: 30.minutes).perform_later(image, resource)
      end
    end
  end

  def temp_directory
    File.join Dir.tmpdir, 'create_ocr'
  end
end
