json.set! '@type', 'search:Hit'
json.annotations do
  # This is the way we trick UV to show the number of hits
  urls = []
  doc[:hit_number].times do |time|
    urls << annotation_url(doc['id'], doc['resource'], time)
  end
  json.array! urls
end
