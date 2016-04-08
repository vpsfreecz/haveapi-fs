module HaveAPI::Fs::Components
  class File < HaveAPI::Fs::Component
    def file?
      true
    end

    def size
      read.length
    end

    def read
      raise NotImplementedError
    end
    
    def write(str)
      raise NotImplementedError
    end

    def raw_open(path, mode, rfusefs = nil)
      nil
    end

    def raw_read(path, offset, size, raw = nil)

    end

    def raw_write(path, offset, size, buf, raw = nil)

    end

    def raw_sync(path, datasync, raw = nil)

    end

    def raw_truncate(path, offset, raw= nil)

    end
    
    def raw_close(path, raw = nil)

    end
  end
end
