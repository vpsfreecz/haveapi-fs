module HaveAPI::Fs::Components
  class ProxyDir < Directory
    def initialize(path)
      super()
      @path = path
    end

    def setup
      super
      
      @dir = ::Dir.new(@path)
    end

    def contents
      @dir.entries[2..-1]
    end

    def times
      st = ::File.stat(@path)
      [st.atime, st.mtime, st.ctime]
    end

    protected
    def new_child(name)
      if child = super
        return child
      end

      real_name = name.to_s
      return unless contents.include?(real_name)
      
      path = ::File.join(@dir.path, real_name)

      if ::File.directory?(path)
        [ProxyDir, path]

      else
        [ProxyFile, path]
      end
    end
  end
end
