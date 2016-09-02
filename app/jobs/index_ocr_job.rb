class IndexOcrJob < ApplicationJob
  queue_as :index

  def perform(resource, image)
    puts "IndexOcrJob: #{image}"
    ocr_indexer = OcrIndexer.new(resource: resource, image: image)
    if ocr_indexer.preconditions_met?
      ocr_indexer.index
    else
      IndexOcrJob.set(wait: 30.minutes).perform_later(resource, image)
    end
  end
end
