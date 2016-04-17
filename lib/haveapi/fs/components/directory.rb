module HaveAPI::Fs::Components
  class Directory < HaveAPI::Fs::Component
    include HaveAPI::Fs::Help

    def directory?
      true
    end

    def contents
      help_contents + %w(.reset .unsaved)
    end

    protected
    def new_child(name)
      return help_file(name) if help_file?(name)

      case name
      when HaveAPI::Fs::Fs::CHECK_FILE
        RFuseCheck

      when :'.reset'
        DirectoryReset

      when :'.unsaved'
        UnsavedList

      when :'.components'
        ComponentList

      when :'.pry'
        HaveAPI::Fs::Components::Pry

      else
        nil
      end
    end
  end
end
