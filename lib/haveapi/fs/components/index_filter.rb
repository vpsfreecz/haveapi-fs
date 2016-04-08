module HaveAPI::Fs::Components
  class IndexFilter < Directory
    attr_reader :resource_dir, :param
    attr_accessor :filters

    def initialize(resource_dir, param)
      super()

      @resource_dir = resource_dir
      @param = param
      @filters = {}
    end

    def contents
      help_contents
    end

    def title
      "Filter by #{@param}"
    end

    protected
    def new_child(value)
      if help_file?(value)
        help_file(value)

      else
        @filters[ @param ] = value.to_s
        IndexFilterValue.new(@resource_dir.resource, @filters)
      end
    end
  end

  class IndexFilterValue < ResourceDir
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

      child.filters = @filters if child.is_a?(IndexFilter)
      child
    end
  end
end
