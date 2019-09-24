class ApiController < ApplicationController

  before_action :authenticate_with_token

  # Including the "destroy" key will set in motion destroying all the OCR
  # related to the Resource including the database records and files.
  def ocr_resource
    if !params[:delete].blank? || !params[:destroy].blank?
      destroyer = OcrDestroyer.new(params[:resource])
      destroyer.destroy
      render json: "success destroying OCR: #{params[:resource]}"
    else
      ResourceOcrJob.perform_later params[:resource], params[:images], params[:callback]
      render json: 'success starting OCR job'
    end
  end

end

__END__

From terminal outside of Vagrant (ie where SCAMS runs):

curl -X POST -H "Content-Type: application/json" -H "Accept: application/json"  -H  "Authorization: Token token=scams_token, user=scams" -k http://localhost:8090/api/ocr_resource -d '{"resource": "gng00126",
"callback": "http://localhost/callback",
"images": ["gng00126_001","gng00126_002"]}' 
