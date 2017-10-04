class AnnotationListJob < ApplicationJob
  queue_as :annotation_list

  def perform(image)
    puts "AnnotationListJob: #{image}"
    alc = AnnotationListCreator.new image
    #if alc.annotation_list_exists? && !ENV['REDO_OCR']
       #puts "AnnotationList already exists for #{image}"
    #elsif alc.preconditions_met?
    
    if alc.preconditions_met?
      alc.create_annotation_lists
    else
      puts "AnnotationListJob: Preconditions not met #{image}"
      AnnotationListJob.set(wait: 5.minutes).perform_later image
    end
  end

end
