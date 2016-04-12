module HaveAPI::Fs::Components
  class ClientVersion < File
    def read
      HaveAPI::Client::VERSION + "\n"
    end
  end
  
  class FsVersion < File
    def read
      HaveAPI::Fs::VERSION + "\n"
    end
  end
  
  class ProtocolVersion < File
    def read
      HaveAPI::Client::PROTOCOL_VERSION + "\n"
    end
  end
end
