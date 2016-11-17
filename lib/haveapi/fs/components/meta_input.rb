module HaveAPI::Fs::Components
  class MetaInput < Directory
    component :meta_input
    help_file :action_input

    def initialize(action_dir, *args)
      super(*args)

      @action_dir = action_dir
    end

    def contents
      super + parameters.keys.map(&:to_s)
    end

    def parameters
      @action_dir.action.instance_variable_get('@spec')[:meta][:global][:input][:parameters]
    end

    def values
      Hash[children.select { |n, c| c.is_a?(Parameter) && c.set? }.map { |n, c| [n, c.value] }]
    end

    def title
      'Input metadata parameters'
    end

    protected
    def new_child(name)
      if child = super
        child

      elsif parameters.has_key?(name)
        [
            Parameter,
            @action_dir.action,
            name,
            :input,
            nil,
            meta: :global,
        ]

      else
        nil
      end
    end
  end
end
