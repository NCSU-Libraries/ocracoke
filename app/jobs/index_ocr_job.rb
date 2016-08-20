class IndexOcrJob < ApplicationJob
  queue_as :index

  def perform(resource, image)
    puts "IndexOcrJob: #{image}"
    ocr_indexer = OcrIndexer.new(resource: resource, image: image)
    ocr_indexer.index
  end
end
