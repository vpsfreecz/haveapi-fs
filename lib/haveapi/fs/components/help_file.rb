require 'erb'

module HaveAPI::Fs::Components
  class HelpFile < File
    def initialize(component, format)
      super()
      @component = @c = component
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
          underscore(name) + ".#{@format}.erb",
      ))
    end

    def layout
      @layout.result(binding { yield })
    end
  end
end
