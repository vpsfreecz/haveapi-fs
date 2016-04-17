module HaveAPI::Fs::Components
  class HtmlHelpFile < HelpFile
    def initialize(*args)
      super
      
      @layout = ERB.new(::File.open(template_path('layout')).read, 0, '-')
      @template = ERB.new(
          ::File.open(template_path(@c.class)).read,
          0, '-'
      )
    end
    
    def read
      layout(@layout) do
        @template.result(binding)
      end
    end

    protected
    def asset(path)
      ::File.join(@context.mountpoint, '.assets', path)
    end
  end
end
