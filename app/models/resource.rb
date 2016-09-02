class Resource < ApplicationRecord
  has_many :images

  def create_pdf
    PdfCreator.new(identifier, image_identifiers).create
  end

  def concatenate_txt
    OcrTxtConcatenator.new(identifier, image_identifiers).concatenate
  end

  def queue_pdf_job
    PdfCreatorJob.perform_later identifier, image_identifiers
  end

  def queue_txt_job
    ConcatenateOcrTxtJob.perform_later identifier, image_identifiers
  end

  def image_identifiers
    images.pluck :identifier
  end

end
