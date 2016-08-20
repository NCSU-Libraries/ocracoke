class OcrIndexer
  include DirectoryFileHelpers

  def initialize(resource:, image:)
    @resource = resource
    @image = image
  end

  def index
    solr = RSolr.connect url: Rails.configuration.iiifsi['solr_url']
    if !File.exist? final_txt_filepath(@image)
      puts "File does not exist: #{final_txt_filepath(@image)}"
    end
    text = File.read final_txt_filepath(@image)
    # FIXME: For some reason the context field cannot have any dashes in it.
    # http://lucene.472066.n3.nabble.com/Suggester-Issue-td4285670.html
    # TODO: Could resource_context_field be multiValued so that we could either make suggestions based on a resource or based on a page image?
    resource_context_field = @resource.gsub('-','_')
    # FIXME: Does suggest_txt need to match JSON word boundaries file?
    suggest_txt = text.split.map{|word| word.gsub(/[^a-zA-Z]/, "").downcase }
    suggest_txt = suggest_txt.uniq
    page = {
      id: @image,
      resource: @resource,
      resource_context_field: resource_context_field,
      txt: text,
      suggest_txt: suggest_txt
    }
    add = solr.add page
    puts "add #{@image}: #{add}"
  end

end
