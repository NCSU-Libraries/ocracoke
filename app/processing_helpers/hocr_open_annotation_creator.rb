class HocrOpenAnnotationCreator

  include CanvasHelpers

  def initialize(hocr_path, granularity)
    @hocr = File.open(hocr_path){ |f| Nokogiri::XML(f) }
    @identifier = File.basename(hocr_path, '.hocr')
    @first_two = @identifier[0,2]
    @granularity = granularity
    @selector = get_selector
  end

  def get_selector
    if @granularity == "word"
     "ocrx_word"
    elsif @granularity == "line"
     "ocr_line"
    elsif @granularity == "paragraph"
      "ocr_par"
    else
      ""
     end
 end

 def resources
    @hocr.xpath(".//*[contains(@class, '#{@selector}')]").map do |chunk|
      text = chunk.text().gsub("\n", ' ').squeeze(' ').strip
      if !text.empty?
        title = chunk['title']
        title_parts = title.split('; ')
        xywh = '0,0,0,0'
        title_parts.each do |title_part|
          if title_part.include?('bbox')
            match_data = /bbox\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/.match title_part
            x = match_data[1].to_i
            y = match_data[2].to_i
            x1 = match_data[3].to_i
            y1 = match_data[4].to_i
            w = x1 - x
            h = y1 - y
            xywh = "#{x},#{y},#{w},#{h}"
          end
        end
        annotation(text, xywh)
       end
    end.compact
  end

  def annotation_list
    {
      :"@context" => "http://iiif.io/api/presentation/2/context.json",
      :"@id" => annotation_list_id,
      :"@type" => "sc:AnnotationList",
      :"@label" => "OCR text granularity of #{@granularity}",
      resources: resources
    }
  end

  def annotation_list_id_base
   File.join Rails.configuration.ocracoke['ocracoke_base_url'], @first_two, @identifier, @identifier + '-annotation-list-' + @granularity
  end

  def annotation_list_id
    annotation_list_id_base + '.json'
  end

 def annotation(chars, xywh)
    {
      :"@id" => annotation_id(xywh),
      :"@type" => "oa:Annotation",
      motivation: "sc:painting",
      resource: {
        :"@type" => "cnt:ContentAsText",
        format: "text/plain",
        chars: chars
      },
      # TODO: use canvas_url_template
      on: on_canvas(xywh)
    }
  end

  def annotation_id(xywh)
    File.join annotation_list_id_base, xywh
  end

  def on_canvas(xywh)
    manifest_canvas_on_xywh(@identifier, xywh)
  end

end



