module HaveAPI::Fs::Components
  class MetaFile < File
    def initialize(path)
      super()
      @path = path
    end

    def read
      ::File.read(@path)
    end
  end
end
