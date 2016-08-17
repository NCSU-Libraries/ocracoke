class SearchController < ApplicationController

  def search
    solr = RSolr.connect url: 'http://localhost:8983/solr/iiifsi'
    solr_params = {
      q: params[:q],
      fq: "resource:#{params[:id]}"
    }
    @response = solr.get '/solr/iiifsi/search', params: solr_params

    @docs = @response["response"]["docs"].map do |doc|
      doc_hits = @response['highlighting'][doc['id']]['txt']
      # Each "hit" here might have more than one match emphasized, so we pull those out now.
      hits = doc_hits.map do |hit|
        hit.scan(/<em>(.*?)<\/em>/).flatten
      end.flatten
      doc[:hit_number] = hits.length
      doc[:hits] = hits
      doc
    end

    @pages_json = {}
    first_two_chars = params[:id][0,2]
    @docs.map do |doc|
      json_file = File.join Rails.configuration.iiifsi['ocr_directory'], first_two_chars, doc['id'], doc['id'] + ".json"
      json = File.read json_file
      page_json = JSON.parse(json)
      @pages_json[doc['id']] = page_json
    end

    # We keep track of how many times a particular word has had a hit so that we
    # pick the correct @pages_json word boundary. This compensates for how there
    # could be more than one hit in a snippet.
    @hits_used = {}
    
    request.format = :json
    respond_to :json
  end
end
