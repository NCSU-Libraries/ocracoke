class ConcatenateOcrJob < ApplicationJob
  queue_as :concatenate

  def perform(resource, images)
    puts "ConcatenateOcrJob: #{resource}"
    concatenator = OcrConcatenator.new(resource, images)
    concatenator.concatenate
    # TODO: Ping another service to let it know it is complete
  end
end
