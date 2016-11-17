module HaveAPI::Fs::Components
  # The root of the filesystem. There is only one instance of this object.
  #
  # This directory contains some special hidden files:
  #  
  #  - `.remote_control` is used for IPC between the file system and executables
  #  - `.cache` contains some statistics about the cache
  #  - `.assets/` contains static files for HTML help files
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
              ProxyDir, 
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
