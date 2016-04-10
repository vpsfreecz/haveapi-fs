module HaveAPI::Fs::Components
  class Directory < HaveAPI::Fs::Component
    include HaveAPI::Fs::Help

    def directory?
      true
    end

    def contents
      help_contents
    end

    protected
    def new_child(name)
      if help_file?(name)
        help_file(name)

      else
        nil
      end
    end
  end
end
