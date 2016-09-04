class WordBoundariesJob < ApplicationJob
  queue_as :word_boundaries

  def perform(image)
    puts "WordBoundsJob: #{image}"
    word_boundaries_creator = WordBoundariesCreator.new(image)
    if word_boundaries_creator.json_exists? && !ENV['REDO_OCR']
      puts "WordBoundaries already exist for #{image}"
    elsif word_boundaries_creator.preconditions_met?
      word_boundaries_creator.create
    else
      puts "WordBoundariesJob: Preconditions not met #{image}"
      WordBoundariesJob.set(wait: 5.minutes).perform_later image
    end
  end
end
