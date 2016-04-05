module HaveAPI::Fuse
  class ListItem < Component
    def initialize(action, dir, data)
      super()

      @action = action
      @dir = dir
      @data = data
    end

    def directory?
      true
    end

    def contents
      @action.params.keys.map(&:to_s)
    end

    protected
    def new_child(name)
      Parameter.new(
          @action,
          name,
          @dir,
          @data
      )
    end
  end
end
