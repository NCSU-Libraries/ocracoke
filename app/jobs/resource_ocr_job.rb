class ResourceOcrJob < ApplicationJob
  queue_as :low

  def perform(resource, images)
    puts "ResourceOcrJob: #{resource}"
    images.each do |image|
      OcrJob.perform_later image
      IndexOcrJob.perform_later resource, image
    end
    ConcatenateOcrJob.perform_later resource, images
  end

end
