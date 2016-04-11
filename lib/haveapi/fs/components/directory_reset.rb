module HaveAPI::Fs::Components
  class DirectoryReset < Executable
    def exec
      parent.reset
      true
    end
  end
end
