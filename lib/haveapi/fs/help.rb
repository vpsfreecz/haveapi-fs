module HaveAPI::Fs
  module Help
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
          Components::HtmlHelpFile.new(self, format)

        when :txt, :md
          Components::MdHelpFile.new(self, :md)

        when :man
          Components::GroffHelpFile.new(self, :md)

        else
          return nil
        end
      end
    end

    def self.included(klass)
      klass.send(:extend, ClassMethods)
      klass.send(:include, InstanceMethods)
    end
  end
end
