class SearchController < ApplicationController

  def search
    solr = RSolr.connect url: 'http://localhost:8983/solr/iiifsi'
    solr_params = {
      q: params[:q],
      fq: "filename:#{params[:id]}"
    }
    @response = solr.get '/solr/iiifsi/query', params: solr_params

    @docs = @response["response"]["docs"].map do |doc|
      doc_hits = @response['highlighting'][doc['id']]['txt']
      doc[:hit_number] = doc_hits.length
      doc[:hits] = doc_hits
      doc
    end

    @pages_json = {}
    @docs.map do |doc|
      json_file = File.join "/access-images/ocr/te/", doc['id'], doc['id'] + ".json"
      json = File.read json_file
      page_json = JSON.parse(json)
      @pages_json[doc['id']] = page_json
    end
    request.format = :json
    respond_to :json
  end
end
