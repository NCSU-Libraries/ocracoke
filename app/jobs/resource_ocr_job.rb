class ResourceOcrJob < ApplicationJob
  queue_as :resource_ocr

  def perform(resource, images)
    puts "ResourceOcrJob: #{resource}"
    images.each do |image|
      OcrJob.perform_later image, resource
    end
    ConcatenateOcrTxtJob.perform_later resource, images
    PdfCreatorJob.perform_later resource, images, 50
  end

end
