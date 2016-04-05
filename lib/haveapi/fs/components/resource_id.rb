module HaveAPI::Fs::Components
  class ResourceId < Parameter
    def initialize(resource_dir, *args)
      super(*args)

      @resource_dir = resource_dir
    end

    def write(str)
      super(str)

      @resource_dir.replace_association(@name, value)
    end
  end
end
