require 'erb'

module HaveAPI::Fs::Components
  class HelpFile < File
    def initialize(component, format)
      super()
      @component = @c = component
      @context = component.context
      @format = format
      @layout = ERB.new(::File.open(template_path('layout')).read, 0, '-')
      @template = ERB.new(
          ::File.open(template_path(@c.class.name.split('::').last)).read,
          0, '-'
      )
    end

    def read
      layout do
        @template.result(binding)
      end
    end

    protected
    def template_path(name)
      ::File.realpath(::File.join(
          ::File.dirname(__FILE__),
          '..', '..', '..', '..',
          'templates',
          'help',
          @format.to_s,
          underscore(name) + ".erb",
      ))
    end

    def layout
      @layout.result(binding { yield })
    end

    def asset(path)
      ::File.join(@context.mountpoint, '.assets', path)
    end
  end
end
