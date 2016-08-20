class OcrJob < ApplicationJob
  queue_as :ocr

  # Provide a way to redo the OCR for an item
  def perform(image, resource=nil)
    puts "OcrJob: #{image}"
    ocr_creator = OcrCreator.new(image)
    if ocr_creator.ocr_exists?
      puts "OCR already exists for #{image}"
    else
      ocr_creator.process
      if resource
        IndexOcrJob.perform_later resource, image
      end
    end
  end

  def temp_directory
    File.join Dir.tmpdir, 'create_ocr'
  end
end
