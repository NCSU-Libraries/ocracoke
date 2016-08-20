namespace :iiifsi do
  task :clear_dev do
    `rm /tmp/create_ocr/*`
    `rm -rf /access-images/ocr/*`
  end
end
