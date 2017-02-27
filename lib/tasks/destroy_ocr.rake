namespace :ocracoke do
  desc 'queue a resource and images for OCR from an NCSU resource identifier'
  task :destroy_ocr, [:id] => :environment do |t, args|
    destroyer = OcrDestroyer.new(args[:id])
    destroyer.destroy
  end
end
