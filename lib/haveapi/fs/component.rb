module HaveAPI::Fs
  module Components ; end

  class Component
    class Children
      attr_accessor :context

      def initialize(ctx)
        @context = ctx
        @store = {}
      end

      def [](k)
        @store[k]
      end

      def []=(k, v)
        if @store.has_key?(k)
          v.invalidate
          v.context.cache.drop_below(v.path)
        end

        v.context = context.clone
        v.context.last.send(:setup_child, k, v)
        @store[k] = v     
      end

      def set(k, v)
        @store[k] = v
      end

      def has_key?(k)
        @store.has_key?(k)
      end

      def clear
        @store.clear
      end

      def each(&block)
        @store.each(&block)
      end

      def select(&block)
        @store.select(&block)
      end

      def detect(&block)
        @store.detect(&block)
      end

      def delete_if(&block)
        @store.delete_if(&block)
      end
    end

    class << self
      def children_reader(*args)
        args.each do |arg|
          define_method(arg) { children[arg] }
        end
      end
    end

    attr_accessor :context, :atime, :mtime, :ctime

    def initialize(bound: false)
      @bound = bound
      @atime = @mtime = @ctime = Time.now
    end

    def setup
      @children = Children.new(context)
    end

    def find(name)
      return @children[name] if @children.has_key?(name)
      c = new_child(name)
      @children.set(name, setup_child(name, c)) if c
    end

    def bound?
      @bound
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

    def reset
      drop_children
      setup
    end

    def title
      self.class.name
    end

    def path
      context.file_path.join('/')
    end

    def abspath
      File.join(
          context.mountpoint,
          path
      )
    end

    def parent
      context.object_path[-2][1]
    end

    def unsaved?(n = nil)
      return @is_unsaved if n && @last_unsaved == n

      child = @children.detect { |_, c| c.unsaved? }

      @last_unsaved = n
      @is_unsaved = !child.nil?
    end

    def invalidate
      @invalid = true
    end

    def invalid?
      @invalid
    end

    protected
    attr_accessor :children

    def new_child(name)
      raise NotImplementedError
    end

    def setup_child(name, c)
      c.context = context.clone
      c.context[ underscore(c.class.name.split('::').last).to_sym ] = c
      c.context.file_path << name.to_s
      c.setup
      c
    end

    def drop_children
      @children.clear
    end

    def changed
      self.mtime = Time.now
    end

    def underscore(str)
      str.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end
  end
end
