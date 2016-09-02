Resque.peek(:concatenate_txt, 0, 30000).each do |ct|
  args = ct['args'].first['arguments']
  pp args
  resource = args.first
  images = args.last
  r = Resource.find_or_create_by(identifier: resource)
  images.each do |image|
    Image.find_or_create_by(identifier: image, resource: r)
  end
end
