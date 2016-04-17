module HaveAPI::Fs
  class Factory
    class << self
      attr_accessor :replacements

      def replace(*args)
        @replacements ||= {}

        if args.size == 2
          @replacements[args[0]] = args[1]

        else
          @replacements.update(args.first)
        end
      end

      def component(klass)
        if @replacements && @replacements.has_key?(klass)
          @replacements[klass]

        else
          klass
        end
      end

      def create(context, name, klass, *args)
        child = component(klass).new(*args)
        c_name = klass.component || klass.name.split('::').last.underscore.to_sym

        child.context = context.clone
        child.context[c_name] = child
        child.context.file_path << name.to_s if name
        child.setup
        child
      end
    end
  end
end
