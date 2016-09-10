class ApiController < ApplicationController

  before_action :authenticate_with_token

  def ocr_resource
    ResourceOcrJob.perform_later params[:resource], params[:images]
    render json: 'success'
  end

end

__END__

From terminal outside of Vagrant (ie where SCAMS runs):

curl -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"resource": "gng00126", "images": ["gng00126_001","gng00126_002","gng00126_003","gng00126_004"]}' -H  "Authorization: Token token=scams_token, user=scams" -k http://localhost:8090/api/ocr_resource
