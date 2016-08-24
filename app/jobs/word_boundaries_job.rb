class WordBoundariesJob < ApplicationJob
  queue_as :word_boundaries

  def perform(image)
    puts "WordBoundsJob: #{image}"
    word_boundaries_creator = WordBoundariesCreator.new(image)
    if word_boundaries_creator.json_exists? && !ENV['REDO_OCR']
      puts "WordBoundaries already exist for #{image}"
    else
      word_boundaries_creator.create
    end
  end
end
