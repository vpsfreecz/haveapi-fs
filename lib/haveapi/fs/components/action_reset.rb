module HaveAPI::Fs::Components
  class ActionReset < Executable
    def initialize(action_dir)
      super()
      @action_dir = action_dir
    end

    def exec
      @action_dir.reset
    end
  end
end
