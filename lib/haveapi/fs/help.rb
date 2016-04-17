module HaveAPI::Fs
  # Included this module to a {Component} to provide help files. All components
  # based on {Components::Directory} already have this module included.
  module Help
    # When searching for a help file, all directories in this list are checked.
    # Add paths to this list for help files of third-party components.
    SEARCH_PATH = [
        ::File.realpath(::File.join(
            ::File.dirname(__FILE__),
            '..', '..', '..',
            'templates',
            'help',
        ))
    ]

    module ClassMethods
      # Specify a name of a help file for this component. By default, the class
      # name is used.
      # @param [Symbol, nil] name
      # @return [Symbol] if name is nil
      def help_file(name = nil)
        if name
          @help_file = name

        else
          @help_file
        end
      end
    end

    module InstanceMethods
      protected
      # List of help files in all formats as symbols.
      # @return [Array<Symbol>]
      def help_files
        %i(html txt md man).map { |v| :"help.#{v}" }
      end

      # List of help files in all formats as strings.
      # @return [Array<String>]
      def help_contents
        help_files.map(&:to_s)
      end

      # Check if `name` is a help file.
      # @param [Symbol] name
      def help_file?(name)
        help_files.include?(name)
      end

      # @return [Components::HelpFile] the recipe for a subclass, as
      #                                {Component#new_child}
      def help_file(name)
        format = name.to_s.split('.').last.to_sym

        case format
        when :html
          [Components::HtmlHelpFile, self, format]

        when :txt, :md
          [Components::MdHelpFile, self, :md]

        when :man
          [Components::GroffHelpFile, self, :md]

        else
          return nil
        end
      end
    end

    class << self
      def included(klass)
        klass.send(:extend, ClassMethods)
        klass.send(:include, InstanceMethods)
      end

      # Search for `name` in paths defined in {SEARCH_PATH}.
      # @return [String]
      def find!(name)
        SEARCH_PATH.each do |s|
          path = ::File.join(s, name)

          return path if ::File.exists?(path)
        end

        raise Errno::ENOENT, "help file '#{name}' not found"
      end
    end
  end
end
