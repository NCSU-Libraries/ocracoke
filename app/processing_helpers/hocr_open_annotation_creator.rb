class HocrOpenAnnotationCreator

  include CanvasHelpers

  def initialize(hocr_path)
    @hocr = File.open(hocr_path){ |f| Nokogiri::XML(f) }
    @identifier = File.basename(hocr_path, '.hocr')
    @first_two = @identifier[0,2]
  end

  def annotation_list
    {
      :"@context" => "http://iiif.io/api/presentation/2/context.json",
      :"@id" => annotation_list_id,
      :"@type" => "sc:AnnotationList",
      resources: resources
    }
  end

  def annotation_list_id
    File.join Rails.configuration.ocracoke['ocracoke_base_url'], @first_two, @identifier, @identifier + '-annotation-list.json'
  end

  def method
    #code
  end

  def resources
    @hocr.xpath(".//*[contains(@class, 'ocr_line')]").map do |line|
      text = line.text().gsub("\n", ' ').squeeze(' ').strip
      if !text.empty?
        title = line['title']
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

  def annotation(chars, xywh)
    {
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

  def on_canvas(xywh)
    manifest_canvas_on_xywh(@identifier, xywh)
  end

end
