module HaveAPI::Fs::Components
  class Root < Directory
    component :root
    
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
        [ResourceDir, @api.resources[name]]

      else
        case name
        when :'.remote_control'
          RemoteControlFile

        when :'.assets'
          [
              MetaDir, 
              ::File.join(
                  ::File.realpath(::File.dirname(__FILE__)),
                  '..', '..', '..', '..',
                  'assets'
              ),
          ]

        when :'.client_version'
          ClientVersion

        when :'.fs_version'
          FsVersion

        when :'.protocol_version'
          ProtocolVersion

        when :'.cache'
          CacheStats

        else
          nil
        end
      end
    end
  end
end
