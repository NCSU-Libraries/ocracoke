namespace :ocracoke do
  desc 'queue a resource and images for OCR from an NCSU resource identifier'
  task :destroy_ocr, [:resource_id] => :environment do |t, args|
    destroyer = OcrDestroyer.new(args[:resource_id])
    destroyer.destroy
  end
end
