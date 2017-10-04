class AnnotationListCreator

  include DirectoryFileHelpers

  def initialize(identifier)
    @identifier = identifier
    @granularity_list = %w[word line paragraph]
  end

 def create_annotation_lists
    @annotation_list = Hash.new("annotation_list")
    @granularity_list.map do |granularity|
       hr = HocrOpenAnnotationCreator.new final_hocr_filepath(@identifier), granularity
       @annotation_list[granularity] = hr.annotation_list
       @list = @annotation_list[granularity].to_json
       write_files(@list, granularity)
     end
 end 

 def write_files(list, granularity)
   outfile = final_annotation_list_filepath(@identifier, granularity)
   File.open(outfile, 'w') do |fh|
     fh.puts @list
   end 
 end 

  def preconditions_met?
    File.exist? final_hocr_filepath(@identifier)
  end

  def annotation_list_exists?
    annotation_list_already_exists?(@identifier)
  end

end
