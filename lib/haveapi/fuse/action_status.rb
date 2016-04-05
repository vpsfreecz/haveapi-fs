module HaveAPI::Fuse
  class ActionStatus < Component
    def initialize(action_dir)
      @action_dir = action_dir
      @v = nil
    end

    def file?
      true
    end

    def read
      value.to_s + "\n"
    end

    def set(v)
      @v = v
    end

    protected
    def value
      case @v
      when true
        1

      when false
        0

      else
        nil
      end
    end
  end
end
