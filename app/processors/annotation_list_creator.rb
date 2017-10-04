class AnnotationListCreator

  include DirectoryFileHelpers

  def initialize(identifier)
    @identifier = identifier
    @granularity_list = %w[word line paragraph]
    @list = annotation_lists
  end

  def annotation_lists
     @granularity_list.map do |granularity|
       hr = HocrOpenAnnotationCreator.new final_hocr_filepath(@identifier), granularity
       hr.annotation_list
     end 
  end 
 
  def create_word_list
    write_file(@list[0].to_json, 'word')
  end
  
  def create_line_list 
    write_file(@list[1].to_json, 'line')
  end 

  def create_paragraph_list
    write_file(@list[2].to_json, 'paragraph')
  end
   
  def write_file(list, type)
    outfile = final_annotation_list_filepath(@identifier, type)
     File.open(outfile, 'w') do |fh|
       fh.puts list
     end 
   end     
 	
  def preconditions_met?
    File.exist? final_hocr_filepath(@identifier)
  end

  def annotation_list_exists?
    annotation_list_already_exists?(@identifier)
  end

end
