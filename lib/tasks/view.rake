namespace :iiifis do
  desc 'download and view all files related to a particular id'
  task :view, [:id] => :environment do |t, args|
    http = HTTPClient.new
    id = args[:id]
    first_two = id[0,2]
    base_ocr_url = "https://ocr.lib.ncsu.edu/ocr/#{first_two}/#{id}/#{id}"
    txt_url = base_ocr_url + '.txt'
    pdf_url = base_ocr_url + '.pdf'
    image_url = "https://iiif-prod02.lib.ncsu.edu/iiif/#{id}/full/full/0/default.jpg"
    base_tmp = File.join Rails.root, 'tmp/iiif-downloads'
    id_directory = File.join base_tmp, id
    FileUtils.mkdir_p id_directory
    puts id_directory
    puts

    puts txt_url
    txt_response = http.get txt_url
    if txt_response.status == 200
      txt_output = File.join id_directory, id + '.txt'
      File.open(txt_output, 'w') do |fh|
        fh.puts txt_response.body
      end
      puts txt_output
      # spawn "exo-open #{txt_output} &"
    else
      puts "No txt"
    end

    puts

    puts image_url
    image_response = http.get image_url
    if image_response.status == 200
      image_output = File.join id_directory, id + '.jpg'
      File.open(image_output, 'wb') do |fh|
        fh.puts image_response.body
      end
      puts image_output
      # spawn "exo-open #{image_output} &"
    else
      puts "No image"
    end

    # pdf_response = http.get pdf_url
    # if pdf_response.status == 200
    #   pdf_output = File.join id_directory, id + '.pdf'
    #   File.open(pdf_output, 'wb') do |fh|
    #     fh.puts pdf_response.body
    #   end
    #   `exo-open #{pdf_output}`
    # else
    #   puts "No pdf"
    # end

  end
end
