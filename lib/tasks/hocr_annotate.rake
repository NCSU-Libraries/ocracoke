namespace :ocracoke do

  desc "create open annotations from hocr file"
  task :hocr_annotation, [:hocr_path, :outfile] => :environment do |t, args|
    hr = HocrOpenAnnotationCreator.new File.expand_path(args[:hocr_path])
    annotations = hr.annotation_list
    puts annotations.to_json
  end

end
