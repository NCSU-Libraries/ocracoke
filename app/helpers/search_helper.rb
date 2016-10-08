module SearchHelper

  include CanvasHelpers

  def annotation_url(id, resource, time)
    # FIXME: Can we use something other than a URN here? What's appropriate/correct?
    "urn:#{params[:id]}:#{id}:annotation#{time}"
  end

end
