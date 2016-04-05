module HaveAPI::Fs
  class ActionInput < Directory
    def initialize(action_dir)
      super()
      @action_dir = action_dir
    end

    def contents
      parameters.keys.map(&:to_s)
    end

    def parameters
      @action_dir.action.input_params
    end

    def values
      Hash[children.select { |n, c| c.set? }.map { |n, c| [n, c.value] }]
    end

    protected
    def new_child(name)
      Parameter.new(@action_dir.action, name, :input)
    end
  end
end
