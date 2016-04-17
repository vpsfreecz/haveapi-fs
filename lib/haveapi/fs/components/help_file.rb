require 'erb'

module HaveAPI::Fs::Components
  class HelpFile < File
    def initialize(component, format)
      super()
      @component = @c = component
      @context = component.context
      @format = format
    end

    protected
    def template_path(klass)
      if klass.is_a?(::String)
        name = klass
        
      else
        name = klass.help_file ? klass.help_file.to_s : klass.name.split('::').last.underscore
      end

      HaveAPI::Fs::Help.find!(::File.join(@format.to_s, name + ".erb"))
    end

    def layout(layout_erb)
      layout_erb.result(binding { yield })
    end
  end
end
