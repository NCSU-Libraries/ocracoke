class Resource < ApplicationRecord
  has_many :images

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
