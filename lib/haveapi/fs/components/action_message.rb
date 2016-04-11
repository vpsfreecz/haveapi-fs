module HaveAPI::Fs::Components
  class ActionMessage < File
    def initialize(action_dir, *args)
      super(*args)
      @action_dir = action_dir
    end

    def read
      ret = @msg.to_s
      ret += "\n" unless ret.empty?
      ret
    end

    def set(msg)
      changed
      @msg = msg
    end
  end
end
