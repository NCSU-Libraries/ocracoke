class Resource < ApplicationRecord

  include DirectoryFileHelpers

  has_many :images

  before_destroy do |image|
    FileUtils.rm_rf directory
  end

  def directory
    directory_for_identifier identifier
  end

  def create_pdf
    PdfCreator.new(identifier, image_identifiers).create
  end

  def concatenate_txt
    OcrTxtConcatenator.new(identifier, image_identifiers).concatenate
  end

  def index_images
    images.each do |image|
      image.index
    end
  end

  def word_boundaries_images
    images.each do |image|
      image.create_word_boundaries
    end
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
