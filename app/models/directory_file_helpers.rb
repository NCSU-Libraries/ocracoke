module DirectoryFileHelpers

  def directory_for_first_two(id)
    first_two_of_identifier = id.slice(0, 2)
    File.join Rails.configuration.iiifsi['ocr_directory'], first_two_of_identifier
  end

  def directory_for_identifier(id)
    File.join directory_for_first_two(id), id
  end

  def final_output_base_filepath(id)
    File.join directory_for_identifier(id), id
  end
  def final_txt_filepath(id)
    final_output_base_filepath(id) + '.txt'
  end
  def final_hocr_filepath(id)
    final_output_base_filepath(id) + '.hocr'
  end
  def final_pdf_filepath(id)
    final_output_base_filepath(id) + '.pdf'
  end
  def final_json_file_filepath(id)
    final_output_base_filepath(id) + '.json'
  end

  # Temporary filepaths
  def temporary_directory_for_identifier(id)
    File.join @temp_directory, id
  end

  def temporary_filepath(id, extension)
    File.join temporary_directory_for_identifier(id), id + extension
  end

  # Based on a identifier determine if all the OCR files already exist.
  # We only check if the txt file exists because some page images processed
  # by tesseract result in no text. In these cases the txt file will exist, but
  # it will be completely empty.
  def ocr_already_exists?(id)
    txt_already_exists?(id) && hocr_already_exists?(id)
  end

  def txt_already_exists?(id)
    File.exist?(final_txt_filepath(id))
  end

  def hocr_already_exists?(id)
    File.size?(final_hocr_filepath(id))
  end

  def json_already_exists?(id)
    File.size?(final_json_file_filepath(id))
  end

  def pdf_already_exists?(id)
    File.size?(final_pdf_filepath(id))
  end

end
