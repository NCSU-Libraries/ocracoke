class OcrJob < ApplicationJob
  queue_as :ocr

  def perform(image)
    puts "OcrJob: #{image}"
    ocr_creator = OcrCreator.new(image)
    ocr_creator.process
  end

  def temp_directory
    File.join Dir.tmpdir, 'create_ocr'
  end
end
