module HaveAPI::Fs::Components
  class DirectoryReset < Executable
    def exec
      parent.reset
    end
  end
end
