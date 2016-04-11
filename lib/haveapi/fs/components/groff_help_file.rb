require 'md2man/roff/engine'

module HaveAPI::Fs::Components
  class GroffHelpFile < MdHelpFile
    def read
      Md2Man::Roff::ENGINE.render(super)
    end
  end
end
