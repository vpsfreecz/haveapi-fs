module HaveAPI::Fs::Components
  class ListItem < Directory
    component :list_item
    
    def initialize(action, dir, data)
      super()

      @action = action
      @dir = dir
      @data = data
    end

    def contents
      @action.params.keys.map(&:to_s)
    end

    protected
    def new_child(name)
      [
          Parameter,
          @action,
          name,
          @dir,
          @data,
      ]
    end
  end
end
