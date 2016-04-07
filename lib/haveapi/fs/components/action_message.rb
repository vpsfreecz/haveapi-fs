module HaveAPI::Fs::Components
  class ActionMessage < File
    def initialize(action_dir)
      @action_dir = action_dir
    end

    def read
      ret = @msg.to_s
      ret += "\n" unless ret.empty?
      ret
    end

    def set(msg)
      @msg = msg
    end
  end
end
