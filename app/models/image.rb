class Image < ApplicationRecord
  belongs_to :resource

  def index
    indexer = OcrIndexer.new(resource: resource.identifier, image: identifier)
    indexer.index
  end

  def ocr
    OcrCreator.new(identifier).process
  end

  def create_word_boundaries
    WordBoundariesCreator.new(identifier).create
  end

  def queue_ocr_job
    OcrJob.perform_later identifier, resource.identifier
  end

  def queue_index_job
    IndexOcrJob.perform_later resource.identifier, identifier
  end

  def queue_word_boundaries_job
    WordBoundariesJob.perform_later identifier
  end

end
