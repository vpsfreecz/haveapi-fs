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
      super + %w(.client_version .fs_version .protocol_version) + \
        @api.resources.keys.map(&:to_s)
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

      else
        case name
        when :'.remote_control'
          RemoteControlFile.new

        when :'.assets'
          MetaDir.new(
              ::File.join(
                  ::File.realpath(::File.dirname(__FILE__)),
                  '..', '..', '..', '..',
                  'assets'
              )
          )

        when :'.client_version'
          ClientVersion.new

        when :'.fs_version'
          FsVersion.new

        when :'.protocol_version'
          ProtocolVersion.new

        when :'.cache'
          CacheStats.new

        else
          nil
        end
      end
    end
  end
end
