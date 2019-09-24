class ResourceOcrJob < ApplicationJob
  queue_as :resource_ocr

  def perform(resource_id, images, callback=nil)
    puts "ResourceOcrJob: #{resource_id}"
    # Make it clear in the database that this resource_id and images need OCR
    resource = Resource.find_or_create_by(identifier: resource_id)
    if callback
      resource.callback = callback
      resource.save
    end
    images.each do |image|
      Image.find_or_create_by(identifier: image, resource: resource)
      OcrJob.perform_later image, resource_id
      AnnotationListJob.perform_later image
    end
    ConcatenateOcrTxtJob.perform_later resource_id, images
    PdfCreatorJob.perform_later resource_id, images, 50
  end

end
