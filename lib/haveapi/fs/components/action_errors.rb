module HaveAPI::Fs::Components
  class ActionErrors < Directory
    class ActionError < File
      def initialize(errors)
        @errors = errors
      end

      def read
        @errors.join("\n") + "\n"
      end
    end

    def initialize(action_dir)
      super()
      @action_dir = action_dir
    end

    def contents
      ret = super
      return ret unless @errors
      ret.concat(@errors.keys.map(&:to_s))
      ret
    end

    def set(errors)
      changed
      @errors = errors
    end

    def title
      'Errors'
    end

    protected
    def new_child(name)
      if child = super
        child

      elsif @errors && @errors.has_key?(name)
        ActionError.new(@errors[name])

      else
        nil
      end
    end
  end
end
