module CanvasHelpers

  def manifest_canvas_id(id)
    template_string = Rails.configuration.ocracoke['canvas_url_template']
    template = Addressable::Template.new template_string
    template.expand(id: id).to_s
  end

  def manifest_canvas_on_xywh(id, xywh)
    manifest_canvas_id(id) + "#xywh=#{xywh}"
  end

end
