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

      def select(&block)
        @store.select(&block)
      end
    end

    class << self
      def children_reader(*args)
        args.each do |arg|
          define_method(arg) { children[arg] }
        end
      end
    end

    attr_accessor :context

    def initialize

    end

    def setup
      @children = Children.new(context)
    end

    def find(name)
      return @children[name] if @children.has_key?(name)
      c = new_child(name)
      @children.set(name, setup_child(name, c)) if c
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

    def read
      raise NotImplementedError
    end
    
    def write(str)
      raise NotImplementedError
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

    def underscore(str)
      str.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end
  end
end
