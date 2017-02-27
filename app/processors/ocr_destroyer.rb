class OcrDestroyer

  include DirectoryFileHelpers

  def initialize(resource_identifier)
    @resource_identifier = resource_identifier
    @resource = Resource.find_by_identifier resource_identifier
  end

  def destroy
    # Destroy Images
    @resource.images.each do |image|
      Rails.logger.info "Destroying Image: #{image.identifier}"
      image.destroy
    end
    # Destroy Resource
    Rails.logger.info "Destroying Resource: #{@resource.identifier}"
    @resource.destroy
  end
end
