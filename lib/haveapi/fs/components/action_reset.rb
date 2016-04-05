module HaveAPI::Fs::Components
  class ActionReset < File
    def initialize(action_dir)
      super()
      @action_dir = action_dir
    end

    def writable?
      true
    end

    def read
      ''
    end

    def write(str)
      return unless str.strip == '1'

      @action_dir.reset
    end
  end
end
