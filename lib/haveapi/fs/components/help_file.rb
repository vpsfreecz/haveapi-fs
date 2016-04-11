require 'erb'

module HaveAPI::Fs::Components
  class HelpFile < File
    def initialize(component, format)
      super()
      @component = @c = component
      @context = component.context
      @format = format
    end

    def read
      layout do
        @template.result(binding)
      end
    end

    protected
    def template_dir
      ::File.realpath(::File.join(
          ::File.dirname(__FILE__),
          '..', '..', '..', '..',
          'templates',
          'help',
          @format.to_s,
      )) 
    end

    def template_path(klass)
      name = klass.help_file ? klass.help_file.to_s : underscore(klass.name.split('::').last)

      ::File.join(
          template_dir,
          underscore(name) + ".erb",
      )
    end

    def layout(layout_erb)
      layout_erb.result(binding { yield })
    end
  end
end
