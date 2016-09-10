class NotificationJob < ApplicationJob
  queue_as :notification

  # Send a notification
  def perform(resource)
    puts "NotificationJob: #{resource}"
    notifier = Notifier.new(resource)
    if notifier.preconditions_met?
      response = notifier.notify
      if response.status == 200
        puts "NotificationJob: complete #{resource}"
      else
        puts "NotificationJob: fail #{resource}"
        raise "NotificationJob response not 200 OK"
      end
    else
      NotificationJob.set(wait: 10.minutes).perform_later(resource)
    end
  end

end
