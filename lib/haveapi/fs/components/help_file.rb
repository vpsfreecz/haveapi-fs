require 'erb'

module HaveAPI::Fs::Components
  class HelpFile < File
    def initialize(component, format)
      super()
      @component = @c = component
      @format = format
      @template = ERB.new(::File.open(template_path).read, 0, '-')
    end

    def read
      @template.result(binding)
    end

    protected
    def template_path
      ::File.realpath(::File.join(
          ::File.dirname(__FILE__),
          '..', '..', '..', '..',
          'templates',
          'help',
          underscore(@c.class.name.split('::').last) + ".#{@format}.erb",
      ))
    end

    def underscore(str)
      str.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end
  end
end
