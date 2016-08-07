module SearchHelper

  def annotation_url(id, filename, time)
    File.join "http://example.com", filename, id, "annotation#{time}"
  end

  def manifest_image_api_id(id)
    # File.join IiifUrl.base_url, id
    File.join "https://iiif.lib.ncsu.edu/iiif/", id
  end

end
