module HaveAPI::Fuse
  class Component
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
  end
end
