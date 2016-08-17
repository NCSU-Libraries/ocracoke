json.set! '@context', 'http://iiif.io/api/search/1/context.json'
json.set! '@id', request.original_url
json.set! '@type', 'search:TermList'
json.ignored ['motivation', 'user']
json.terms @terms, partial: 'suggest/term', as: :term
