module HaveAPI::Fs::Components
  class Root < Directory
    def initialize()
      super()
    end

    def setup
      super
      @api = context.fs.api
    end

    def contents
      @api.resources.keys.map(&:to_s) + help_contents
    end

    def resources
      @api.resources
    end

    def title
      context.url
    end

    protected
    def new_child(name)
      if @api.resources.has_key?(name)
        ResourceDir.new(@api.resources[name])

      elsif name == :'.assets'
        MetaDir.new(
            ::File.join(
                ::File.realpath(::File.dirname(__FILE__)),
                '..', '..', '..', '..',
                'assets'
            )
        )

      elsif help_file?(name)
        help_file(name)

      else
        nil
      end
    end
  end
end
