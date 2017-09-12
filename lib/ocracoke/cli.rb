module Ocracoke
  class CLI < Thor

    # Adapted from http://stackoverflow.com/a/24829698/620065
    # Add a name for the option that allows for more variability
    class << self
      def add_shared_option(name, options = {})
        @shared_options = {} if @shared_options.nil?
        @shared_options[name] =  options
      end

      def shared_options(*option_names)
        option_names.each do |option_name|
          opt =  @shared_options[option_name]
          raise "Tried to access shared option '#{option_name}' but it was not previously defined" if opt.nil?
          option option_name, opt
        end
      end
    end

    add_shared_option :image, aliases: '-i', type: :string, required: true
    add_shared_option :resource, aliases: '-r', type: :string, required: true

    desc 'ocr', 'run ocr process'
    shared_options :image, :resource
    def ocr
      OcrJob.perform_later options[:image], options[:resource]
    end

    desc 'annotation list job', 'run annotation list process'
    shared_options :image
    def annotate
      AnnotationListJob.perform_later options[:image]
    end

  end
end
