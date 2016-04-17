module HaveAPI::Fs::Components
  # Used to open developer console.
  class Pry < Executable
    def exec
      require 'pry'
      binding.pry
    end
  end
end
