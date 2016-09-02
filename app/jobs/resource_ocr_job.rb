class ResourceOcrJob < ApplicationJob
  queue_as :resource_ocr

  def perform(resource, images)
    puts "ResourceOcrJob: #{resource}"
    # Make it clear in the database that this resource and images need OCR
    r = Resource.find_or_create_by(identifier: resource)
    images.each do |image|
      Image.find_or_create_by(identifier: image, resource: r)
      OcrJob.perform_later image, resource
    end
    ConcatenateOcrTxtJob.perform_later resource, images
    PdfCreatorJob.perform_later resource, images, 50
  end

end
