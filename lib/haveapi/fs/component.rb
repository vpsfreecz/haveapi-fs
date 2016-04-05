module HaveAPI::Fs
  module Components ; end

  class Component
    class << self
      def children_reader(*args)
        args.each do |arg|
          define_method(arg) { children[arg] }
        end
      end
    end

    def initialize
      @children = {}
    end

    def find(name)
      return @children[name] if @children.has_key?(name)
      c = new_child(name)
      @children[name] = c if c
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

    protected
    attr_accessor :children

    def new_child(name)
      raise NotImplementedError
    end

    def drop_children
      @children.clear
    end
  end
end
