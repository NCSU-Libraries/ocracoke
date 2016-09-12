class SuggestController < ApplicationController

  def suggest
    solr = RSolr.connect url: Rails.configuration.ocracoke['solr_url']
    solr_params = {
      'suggest.q' => params[:q],
      # Filter the results to the context of the resource.
      # It is necessary to remove the dashes. If we try to store the resource identifier with dashes then we fail to get the results we expect. Solr does something we don't want it to with the value of this parameter when it has a dash.
      'suggest.cfq' => params[:id].gsub('-','_')
    }
    # FIXME:iiifsi
    @response = solr.get 'suggest', params: solr_params
    suggester = @response['suggest']['suggester']
    suggestion_words = suggester.keys
    terms = suggestion_words.map do |suggestion_word|
      suggester[suggestion_word]['suggestions'].map{|suggestion| suggestion['term']}
    end

    @terms = terms.flatten.uniq

    request.format = :json
    respond_to :json
  end

end
