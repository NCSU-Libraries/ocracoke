# Uses hOCR to create a JSON word boundaries file.
class WordBoundariesCreator

  include DirectoryFileHelpers

  def initialize(id)
    @id = id
  end

  def create
    doc = File.open(final_hocr_filepath(@id)) { |f| Nokogiri::HTML(f) }
    json = {}
    doc.css('span.ocrx_word').each do |span|
      text = span.text
      next if text.length < 3
      # Filter out non-word characters
      word_match = text.match /\w+/
      next if word_match.nil?

      title = span['title']
      info = parse_hocr_title(title)
      text.split('-').each do |word_part|
        json[word_part] ||= []        
        json[word_part] << info
      end
    end
    File.open(final_json_file_filepath(@id), 'w') do |fh|
      fh.puts json.to_json
    end

    if hocr_exists?
      image = Image.find_by(identifier: @id)
      image.json = DateTime.now
      image.save
    end
  end

  def preconditions_met?
    hocr_exists?
  end

  def hocr_exists?
    hocr_already_exists?(@id)
  end

  def json_exists?
    json_already_exists?(@id)
  end

  private

  def parse_hocr_title(title)
    parts = title.split(';').map(&:strip)
    info = {}
    parts.each do |part|
      sections = part.split(' ')
      sections.shift
      if /^bbox/.match(part)
        x0, y0, x1, y1 = sections
        info['x0'], info['y0'], info['x1'], info['y1'] = [x0.to_i, y0.to_i, x1.to_i, y1.to_i]
      elsif /^x_wconf/.match(part)
        c = sections.first
        info['c'] = c.to_i
      end
    end
    info
  end

end
