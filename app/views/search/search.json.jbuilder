json.set! '@context', 'http://iiif.io/api/search/0/context.json'
json.set! '@id', request.original_url
json.set! '@type', 'sc:AnnotationList'
json.startIndex 0

json.within do
  json.ignored []
  json.total 1 # FIXME
  json.set! '@type', 'sc:Layer'
end

json.hits @docs, partial: 'search/hit', as: :doc

# We rework this into individual resource_docs/annotations so that
# we trick UV into showing the number of hits for each page.
resource_docs = []
@docs.each do |doc|
  doc[:hit_number].times do |time|
    word = doc[:hits][time]
    new_doc = {id: doc['id'], resource: doc['resource'], time: time, word: word}
    resource_docs << new_doc
  end
end

json.resources resource_docs, partial: 'search/resource', as: :doc
