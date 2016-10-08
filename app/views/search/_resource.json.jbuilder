json.set! "@id", annotation_url(doc[:id], doc[:resource], doc[:time])
json.set! '@type', 'oa:Annotation'
json.motivation 'sc:painting'

json.resource do
  json.set! '@type',  "cnt:ContentAsText"
  json.chars doc[:word]
end

page_word_list = @pages_json[doc[:id]]
xywh = if !@pages_json[doc[:id]] || page_word_list[doc[:word]].nil?
  "0,0,0,0"
else
  word_bounds = page_word_list[doc[:word]].shift
  # FIXME: This is the wrong place to set all of these to integers
  if word_bounds
    x = word_bounds["x0"].to_i
    y = word_bounds["y0"].to_i
    w = word_bounds["x1"].to_i - word_bounds["x0"].to_i
    h = word_bounds["y1"].to_i - word_bounds["y0"].to_i
    "#{x},#{y},#{w},#{h}"
  else
    "0,0,0,0"
  end
end

# FIXME: How to make this so it is possible to have different canvas URLs to
#        match each institution's own URLs to canvases as found in their
#        Presentation manifests?
json.on manifest_canvas_on_xywh(doc[:id], xywh) #manifest_canvas_id(doc[:id]) + "#xywh=#{xywh}"
