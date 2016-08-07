module SearchHelper

  def annotation_url(id, filename, time)
    File.join id, filename, "annotation#{time}"
  end

  def manifest_image_api_id(id)
    # File.join IiifUrl.base_url, id
    File.join "http://iiif.lib.ncsu.edu/iiif/", id
  end

end
