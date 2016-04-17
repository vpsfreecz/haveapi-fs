module HaveAPI::Fs
  # All built-in components are stored in this module.
  module Components ; end

  # The basic building block of the file system. Every directory and file is
  # represented by a subclass of this class.
  class Component
    # An encapsulation of a Hash to store child components.
    class Children
      attr_accessor :context

      # @param [HaveAPI::Fs::Context] ctx
      def initialize(ctx)
        @context = ctx
        @store = {}
      end

      def [](k)
        @store[k]
      end

      # Replace a child named `k` by a new child represented by `v`. The old
      # child, if present, is invalidated and dropped from the cache.
      # {Factory} is used to create an instance of `v`.
      # 
      # @param [Symbol] k
      # @param [Array] v
      def []=(k, v)
        if @store.has_key?(k)
          @store[k].invalidate
          @store[k].context.cache.drop_below(@store[k].path)
        end

        @store[k] = Factory.create(@context, k, *v)
      end

      def set(k, v)
        @store[k] = v
      end

      %i(has_key? clear each select detect delete_if).each do |m|
        define_method(m) do |*args, &block|
          @store.send(m, *args, &block)
        end
      end
    end

    class << self
      # Define reader methods for child components.
      def children_reader(*args)
        args.each do |arg|
          define_method(arg) { children[arg] }
        end
      end

      # Set or get a component name. Component name is used for finding
      # components within a {Context}.
      #
      # @param [Symbol] name
      # @return [nil] if name is set
      # @return [Symbol] if name is nil
      def component(name = nil)
        if name
          @component = name

        else
          @component
        end
      end

      # Pass component name to the subclass.
      def inherited(subclass)
        subclass.component(@component)
      end
    end

    attr_accessor :context, :atime, :mtime, :ctime

    # @param [Boolean] bound
    def initialize(bound: false)
      @bound = bound
      @atime = @mtime = @ctime = Time.now
    end

    # Called by {Factory} when the instance is prepared. Subclasses must call
    # this method.
    def setup
      @children = Children.new(context)
    end

    # Attempt to find a child component with `name`.
    #
    # @return [HaveAPI::Fs::Component] if found
    # @return [nil] if not found
    def find(name)
      return @children[name] if @children.has_key?(name)
      c = new_child(name)

      @children.set(name, Factory.create(context, name, *c)) if c
    end

    # Attempt to find and use nested components with `names`. Each name is for
    # the next descendant. If the target component is found, it and all
    # components in its path will be bound. Bound components are not
    # automatically deleted when not in use.
    def use(*names)
      ret = self
      path = []

      names.each do |n|
        ret = ret.find(n)
        return if ret.nil?
        path << ret
      end

      path.each { |c| c.bound = true }

      ret
    end

    def bound?
      @bound
    end

    def bound=(b)
      @bound = b
    end

    def directory?
      !file?
    end

    def file?
      !directory?
    end

    def readable?
      true
    end

    def writable?
      false
    end

    def executable?
      false
    end

    def contents
      raise NotImplementedError
    end

    def times
      [@atime, @mtime, @ctime]
    end

    # Shortcut for {#drop_children} and {#setup}.
    def reset
      drop_children
      setup
    end

    def title
      self.class.name
    end

    # @return [String] path of this component in the tree without the leading /
    def path
      context.file_path.join('/')
    end

    # @return [String] absolute path of this component from the system root
    def abspath
      File.join(
          context.mountpoint,
          path
      )
    end

    def parent
      context.object_path[-2][1]
    end

    # A component is unsaved if it or any of its descendants has been modified
    # and not saved.
    #
    # @param [Integer] n used to determine the result just once per the same `n`
    # @return [Boolean]
    def unsaved?(n = nil)
      return @is_unsaved if n && @last_unsaved == n

      child = @children.detect { |_, c| c.unsaved? }

      @last_unsaved = n
      @is_unsaved = !child.nil?
    end

    # Mark the component and all its descendats as invalid. Invalid components
    # can still be in the cache and are dropped on hit.
    def invalidate
      @invalid = true

      children.each { |_, c| c.invalidate }
    end

    def invalid?
      @invalid
    end

    protected
    attr_accessor :children

    # Called to create a component for a child with `name` if this child is not
    # yet or not anymore in memory. All subclasses should extend this method to
    # add their own custom contents.
    #
    # @param [Symbol] name
    # @return [Array] the array describes the new child to be created by
    #                 {Factory}. The first item is a class name and
    #                 the rest are arguments to its constructor.
    # @return [nil] if the child does not exist
    def new_child(name)
      raise NotImplementedError
    end

    # Drop all children from the memory and clear them from the cache.
    def drop_children
      @children.clear
      context.cache.drop_below(path)
    end

    # Update the time of last modification.
    def changed
      self.mtime = Time.now
    end
  end
end
