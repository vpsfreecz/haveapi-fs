module HaveAPI::Fs::Components
  class ActionInput < Directory
    attr_reader :action_dir

    def initialize(action_dir)
      super()
      @action_dir = action_dir
    end

    def contents
      parameters.keys.map(&:to_s) + help_contents
    end

    def parameters
      @action_dir.action.input_params
    end

    def values
      Hash[children.select { |n, c| c.set? }.map { |n, c| [n, c.value] }]
    end

    protected
    def new_child(name)
      if @action_dir.action.input_params.has_key?(name)
        Parameter.new(@action_dir.action, name, :input)

      elsif help_file?(name)
        help_file(name)

      else
        nil
      end
    end
  end
end
