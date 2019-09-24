class Notifier

  def initialize(resource)
    @resource = resource
  end

  def notify
    http = HTTPClient.new
    http.post url, notification_data.to_json, headers
  end

  def preconditions_met?
    # TODO: set preconditions on sending the notification. For now we only send
    # this message after a PdfCreatorJob is completed so we just set it to true.
    true
  end

  def notification_data
    {resource: @resource.identifier}
  end

  def headers
    head = { 'Content-Type' => 'application/json' }
    if token
      head['Authorization'] = "Token token=#{token}, user=ocr"
    end
    head
  end

  def url
    if @resource.callback
      @resource.callback
    elsif notification_config
      notification_config['url']
    end
  end

  # If there's host_token config and a callback URI, then use that.
  # Otherwise fall back to fixed config.
  # Finally just don't send a token at all.
  def token
    if notification_config && notification_config['host_token'] && @resource.callback # we need to have a token available for this service
      notification_config['host_token'][notification_host]
    elsif notification_config && notification_config['token']
      notification_config['token']
    else
      nil # send no token; assume no authorization needed
    end
  end

  def notification_host
    Addressable::URI.parse(@resource.callback).try(:host)
  end

  def notification_config
    Rails.configuration.ocracoke['notification']
  end

end
