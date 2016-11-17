module HaveAPI::Fs::Components
  class MetaOutput < Directory
    component :meta_output
    help_file :action_output
    attr_accessor :data
    attr_reader :scope

    def initialize(action_dir, scope, data = nil, *args)
      super(*args)

      @action_dir = action_dir
      @scope = scope
      @data = data
    end

    def contents
      ret = super
      return ret unless @data

      ret.concat(parameters.keys.map(&:to_s))
      ret
    end

    def parameters
      @action_dir.action.instance_variable_get('@spec')[:meta][@scope][:output][:parameters]
    end

    def title
      'Output metadata parameters'
    end

    protected
    def new_child(name)
      if child = super
        child

      elsif !@data
        nil

      elsif parameters.has_key?(name)
        [
            Parameter,
            @action_dir.action,
            name,
            :output,
            @data,
            meta: @scope,
        ]

      else
        nil
      end
    end
  end
end
