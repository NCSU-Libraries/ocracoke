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
    {resource: @resource}
  end

  def headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Token token=#{token}, user=ocr"
    }
  end

  def url
    notification_config['url']
  end

  def token
    notification_config['token']
  end

  def notification_config
    Rails.configuration.iiifsi['notification']
  end


end
