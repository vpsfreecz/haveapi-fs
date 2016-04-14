module HaveAPI::Fs::Components
  class Pry < Executable
    def exec
      require 'pry'
      binding.pry
    end
  end
end
