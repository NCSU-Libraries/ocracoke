class ResourceOcrJob < ApplicationJob
  queue_as :resource_ocr

  def perform(resource, images)
    puts "ResourceOcrJob: #{resource}"
    images.each do |image|
      OcrJob.perform_later image, resource
    end
    ConcatenateOcrJob.perform_later resource, images
  end

end
