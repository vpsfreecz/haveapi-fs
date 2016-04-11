module HaveAPI::Fs::Components
  class ActionExec < Executable
    def initialize(action_dir, *args)
      super(*args)
      @action_dir = action_dir
    end

    def exec
      @action_dir.exec
    end
  end
end
