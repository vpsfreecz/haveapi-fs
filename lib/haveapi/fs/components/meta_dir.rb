module HaveAPI::Fs::Components
  class MetaDir < Directory
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
      real_name = name.to_s
      return unless contents.include?(real_name)
      
      path = ::File.join(@dir.path, real_name)

      if ::File.directory?(path)
        MetaDir.new(path)

      else
        MetaFile.new(path)
      end
    end
  end
end
