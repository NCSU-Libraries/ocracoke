module SearchHelper

  def annotation_url(id, resource, time)
    # FIXME: Can we use something other than a URN here? What's appropriate/correct?
    "urn:#{params[:id]}:#{id}:annotation#{time}"
  end

  def manifest_image_api_id(id)
    template_string = Rails.configuration.ocracoke['canvas_url_template']
    template = Addressable::Template.new template_string
    template.expand(id: id).to_s
  end

end
