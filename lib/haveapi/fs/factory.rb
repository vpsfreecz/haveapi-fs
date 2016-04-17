module HaveAPI::Fs
  # The Factory is used to create instances of new components and can be used
  # to replace specific components by different ones, thus allowing to change
  # their behaviour.
  class Factory
    class << self
      # @!attribute replacements
      #   @return [Hash] collection of all replacements
      attr_accessor :replacements

      # Replace a component class by a different class. This method has two
      # forms. Either call it with a hash of replacements or with two arguments,
      # where the first is the class to be replaced and the second the class
      # to replace it with.
      def replace(*args)
        @replacements ||= {}

        if args.size == 2
          @replacements[args[0]] = args[1]

        else
          @replacements.update(args.first)
        end
      end

      # Resolves the class for component `klass`, i.e. it checks if there is a
      # replacement for `klass` to return instead.
      #
      # @return [Class]
      def component(klass)
        if @replacements && @replacements.has_key?(klass)
          @replacements[klass]

        else
          klass
        end
      end

      # Create a new component with `klass` and its constructor's arguments
      # in `args`.
      #
      # @param [HaveAPI::Fs::Context] context
      # @param [Symbol] name
      # @param [Class] klass
      # @param [Array] args
      # @return [Component]
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
