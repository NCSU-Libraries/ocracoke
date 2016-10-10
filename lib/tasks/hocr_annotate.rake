namespace :ocracoke do

  desc "create open annotations from hocr file"
  task :hocr_annotation, [:hocr_path, :outfile] => :environment do |t, args|
    hr = HocrOpenAnnotationCreator.new File.expand_path(args[:hocr_path])
    annotations = hr.annotation_list
    puts annotations.to_json
  end

  desc "process backlog of annotions from hocr files already created"
  task :hocr_annotation_backlog => :environment do
    directory_glob = File.join Rails.configuration.ocracoke['ocr_directory'], '*/*'
    Dir.glob(directory_glob).each do |directory|
      # This only works in the case when images have an underscore and resources don't
      basename = File.basename directory
      hocr = File.join directory, basename + '.hocr'
      if File.exist?(hocr)
        AnnotationListJob.perform_later basename
      end
    end
  end

end
