module HaveAPI::Fs::Components
  class ActionExec < Executable
    def initialize(action_dir)
      super()
      @action_dir = action_dir
    end

    def exec
      @action_dir.exec
    end
  end
end
