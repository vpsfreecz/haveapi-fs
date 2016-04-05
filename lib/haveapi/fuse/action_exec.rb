module HaveAPI::Fuse
  class ActionExec < Component
    def initialize(action_dir)
      super()
      @action_dir = action_dir
    end

    def file?
      true
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
