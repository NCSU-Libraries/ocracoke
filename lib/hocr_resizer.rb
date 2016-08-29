class HocrResizer

  attr_accessor :hocr, :percentage

  # Given t
  def initialize(hocr_path)
    @hocr = File.open(hocr_path){ |f| Nokogiri::XML(f) }
    @new_hocr = @hocr.dup
  end

  def resize(percentage=50)
    @percentage = percentage
    @pct = percentage/100.0
    nodes_with_title.each do |node|
      title = node['title']
      title_parts = title.split('; ')

      new_title_parts = title_parts.map do |title_part|
        if title_part.include?('bbox')
          match_data = /bbox\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/.match title_part
          x0 = (match_data[1].to_i * @pct).round
          y0 = (match_data[2].to_i * @pct).round
          x1 = (match_data[3].to_i * @pct).round
          y1 = (match_data[4].to_i * @pct).round
          # byebug
          "bbox #{x0} #{y0} #{x1} #{y1}"
        elsif title_part.include?('baseline')
          # https://github.com/tesseract-ocr/tesseract/wiki/FAQ#how-to-interpret-hocr-baseline-output
          b, slope, constant_term = title_part.split(' ')
          slope = slope.to_f * @pct
          constant_term = constant_term.to_f * @pct
          "baseline #{slope} #{constant_term}"
        else
          title_part
        end
      end

      node['title'] = new_title_parts.join('; ')
    end
  end

  def nodes_with_title
    @new_hocr.xpath "//*[contains(@title, 'bbox')]"
  end

  def save(path)
    File.open(File.expand_path(path), 'w') do |fh|
      fh.puts @new_hocr.to_xhtml
    end
  end

end

__END__
bbox: 'bbox((\s+\d+){4})'
baseline: 'baseline((\s+[\d\.\-]+){2})'
ocr_line
ocrx_word

ocr_carea
ocr_par


baseline: The two numbers are the slope (1st number) and constant term (2nd number) of a linear equation describing the baseline relative to the bottom left of the bounding box. For a linear equation is n = 1, so the first number is p1 and the second number p0 and the equation describing the base line is y = p1 * x + p0.

From /vagrant:

wget https://iiif.lib.ncsu.edu/iiif/technician-1977-02-11_0001/full/pct:50/0/default.jpg -O ./tmp/technician-1977-02-11_0001/technician-1977-02-11_0001.jpg

bin/rake iiifsi:hocr_resize[/access-images/ocr/te/technician-1977-02-11_0001/technician-1977-02-11_0001.hocr,50,./tmp/technician-1977-02-11_0001/technician-1977-02-11_0001.hocr] && hocr-pdf ./tmp/technician-1977-02-11_0001 > ./tmp/technician-1977-02-11_0001/technician-1977-02-11_0001.pdf
