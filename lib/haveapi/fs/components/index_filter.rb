module HaveAPI::Fs::Components
  class IndexFilter < Directory
    attr_reader :resource_dir
    attr_accessor :filters

    def initialize(resource_dir, param)
      super()

      @resource_dir = resource_dir
      @param = param
      @filters = {}
    end

    def contents
      []
    end

    protected
    def new_child(value)
      @filters[ @param ] = value.to_s
      IndexFilterValue.new(@resource_dir.resource, @filters)
    end
  end

  class IndexFilterValue < ResourceDir
    def initialize(resource, filters)
      super(resource)

      @filters = filters
      
      filters.each do |k, v|
        @index.find(:input).find(k).write(v)
      end
    end

    protected
    def new_child(name)
      child = super(name)
      return child unless child

      child.filters = @filters if child.is_a?(IndexFilter)
      child
    end
  end
end
