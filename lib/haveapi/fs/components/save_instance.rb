module HaveAPI::Fs::Components
  class SaveInstance < Executable
    def initialize(resource_dir, *args)
      super(*args)
      @resource_dir = resource_dir
    end
    def exec
      @resource_dir.save
    end
  end
end
