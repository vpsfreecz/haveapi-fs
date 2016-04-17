module HaveAPI::Fs::Components
  class IndexFilter < Directory
    component :index_filter
    attr_reader :resource_dir, :param, :filters

    def initialize(resource_dir, param, filters = {})
      super()

      @resource_dir = resource_dir
      @param = param
      @filters = filters
    end

    def title
      "Filter by #{@param}"
    end

    protected
    def new_child(value)
      if child = super
        child
      
      else
        f = @filters.clone
        f[ @param ] = value.to_s
        [IndexFilterValue, @resource_dir.resource, f]
      end
    end
  end

  class IndexFilterValue < ResourceDir
    component :resource_dir
    help_file :resource_dir

    def initialize(resource, filters)
      super(resource)

      @filters = filters
    end

    def setup
      super

      @filters.each do |k, v|
        @index.find(:input).find(k).write(v)
        @last = v
      end
    end

    def title
      @last.to_s
    end

    protected
    def new_child(name)
      child = super(name)
      return child unless child

      child << @filters.clone if [child].flatten.first == IndexFilter
      child
    end
  end
end
