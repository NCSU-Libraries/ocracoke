module SearchHelper

  def annotation_url(id, resource, time)
    # FIXME: Can we use something other than a URN here? What's appropriate/correct?
    "urn:#{params[:id]}:#{id}:annotation#{time}"
  end

  def manifest_image_api_id(id)
    # File.join IiifUrl.base_url, id
    File.join IiifUrl.base_url, id
  end

end
