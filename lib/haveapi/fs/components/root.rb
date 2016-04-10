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
      super + @api.resources.keys.map(&:to_s)
    end

    def resources
      @api.resources
    end

    def title
      context.url
    end

    protected
    def new_child(name)
      if child = super
        child
      
      elsif @api.resources.has_key?(name)
        ResourceDir.new(@api.resources[name])

      elsif name == :'.remote_control'
        RemoteControlFile.new

      elsif name == :'.assets'
        MetaDir.new(
            ::File.join(
                ::File.realpath(::File.dirname(__FILE__)),
                '..', '..', '..', '..',
                'assets'
            )
        )

      else
        nil
      end
    end
  end
end
