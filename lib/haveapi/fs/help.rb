module HaveAPI::Fs
  module Help
    SEARCH_PATH = [
        ::File.realpath(::File.join(
            ::File.dirname(__FILE__),
            '..', '..', '..',
            'templates',
            'help',
        ))
    ]

    module ClassMethods
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
      def help_files
        %i(html txt md man).map { |v| :"help.#{v}" }
      end

      def help_contents
        help_files.map(&:to_s)
      end

      def help_file?(name)
        help_files.include?(name)
      end

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
