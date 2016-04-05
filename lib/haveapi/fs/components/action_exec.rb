module HaveAPI::Fs::Components
  class ActionExec < File
    def initialize(action_dir)
      super()
      @action_dir = action_dir
    end

    def writable?
      true
    end

    def read
      "ahahahahha\n"
    end

    def write(str)
      @action_dir.exec if str.strip == '1'
    end
  end
end
