module HaveAPI::Fs::Components
  # Base class for all components that act as directories.
  #
  # Every directory contains some special hidden files:
  #
  #  - `.components` contains a list of all descendant component objects that are
  #    created in memory
  #  - `.pry` is an executable that opens a developer console
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
