namespace :ocracoke do

  desc "resize hocr file"
  task :hocr_resize, [:hocr_path,:percentage,:outfile] => :environment do |t, args|
    hr = HocrResizer.new File.expand_path args[:hocr_path]
    hr.resize args[:percentage].to_i
    hr.save File.expand_path(args[:outfile])
  end

end
