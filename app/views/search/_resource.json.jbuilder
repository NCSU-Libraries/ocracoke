
json.set! "@id", annotation_url(doc[:id], doc[:filename], doc[:time])
json.set! '@type', 'oa:Annotation'
json.motivation 'sc:painting'

match_data = doc[:snippet].match /<em>(.*?)<\/em>/
word = match_data[1]
# wordd = word.downcase

json.resource do
  json.set! '@type',  "cnt:ContentAsText"
  json.chars word
end

page_word_list = @pages_json[doc[:id]]
xywh = if !@pages_json[doc[:id]] || page_word_list[word].nil? 
  "0,0,0,0"
else
  word_bounds = page_word_list[word].shift
  # FIXME: This is the wrong place to set all of these to integers
  x = word_bounds["x0"].to_i
  y = word_bounds["y0"].to_i
  w = word_bounds["x1"].to_i - word_bounds["x0"].to_i
  h = word_bounds["y1"].to_i - word_bounds["y0"].to_i
  "#{x},#{y},#{w},#{h}"
end

json.on manifest_image_api_id(doc[:id]) + "/canvas#xywh=#{xywh}"
