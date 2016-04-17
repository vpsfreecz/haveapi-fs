module HaveAPI::Fs::Components
  class MdHelpFile < HelpFile
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
    def safe_print(str)
      str.to_s.gsub('_', '\_')
    end
  end
end
