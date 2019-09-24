class NotificationJob < ApplicationJob
  queue_as :notification

  # Send a notification
  def perform(resource)
    puts "NotificationJob: #{resource.identifier}"
    notifier = Notifier.new(resource)
    if notifier.preconditions_met?
      response = notifier.notify
      if response.status == 200
        puts "NotificationJob: complete #{resource.identifier}"
      else
        puts "NotificationJob: fail #{resource.identifier}"
        raise "NotificationJob response not 200 OK. #{response.body}"
      end
    else
      NotificationJob.set(wait: 10.minutes).perform_later(resource)
    end
  end

end
