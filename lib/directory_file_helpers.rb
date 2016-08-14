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
  def temporary_filepath(id, extension)
    File.join @temp_directory, id + extension
  end

  # Based on a identifier determine if all the OCR files already exist
  def ocr_already_exists?(id)
    File.size?(final_txt_filepath(id)) &&
    File.size?(final_hocr_filepath(id)) #&& File.size?(final_pdf_filepath(id))
  end

end
