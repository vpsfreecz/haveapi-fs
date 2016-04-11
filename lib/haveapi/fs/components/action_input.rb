module HaveAPI::Fs::Components
  class ActionInput < Directory
    attr_reader :action_dir

    def initialize(action_dir, *args)
      super(*args)
      @action_dir = action_dir
    end

    def contents
      super + parameters.keys.map(&:to_s)
    end

    def parameters
      @action_dir.action.input_params
    end

    def values
      Hash[children.select { |n, c| c.set? }.map { |n, c| [n, c.value] }]
    end

    def title
      'Input parameters'
    end

    protected
    def new_child(name)
      if child = super
        child

      elsif @action_dir.action.input_params.has_key?(name)
        Parameter.new(@action_dir.action, name, :input)

      else
        nil
      end
    end
  end
end
