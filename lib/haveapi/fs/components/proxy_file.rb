module HaveAPI::Fs::Components
  class ProxyFile < File
    def initialize(path)
      super()
      @path = path
    end

    def times
      st = ::File.stat(@path)
      [st.atime, st.mtime, st.ctime]
    end

    def size
      ::File.size(@path)
    end

    def read
      ::File.read(@path)
    end
  end
end
