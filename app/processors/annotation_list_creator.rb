class AnnotationListCreator

  include DirectoryFileHelpers

  def initialize(identifier)
    @identifier = identifier
  end

  def annotation_list
    hr = HocrOpenAnnotationCreator.new final_hocr_filepath(@identifier)
    if @annotation_list
      @annotation_list
    else
      @annotation_list = hr.annotation_list
    end
  end

  def create
    outfile = final_annotation_list_filepath(@identifier)
    File.open(outfile, 'w') do |fh|
      fh.puts annotation_list.to_json
    end
  end

  def preconditions_met?
    File.exist? final_hocr_filepath(@identifier)
  end

  def annotation_list_exists?
    annotation_list_already_exists?(@identifier)
  end

end
