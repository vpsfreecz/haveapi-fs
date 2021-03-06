module HaveAPI::Fs
  # Every component has its own Context instance and passes it along to its
  # children. Context is used to pass information from the root of the tree
  # to all its branches and leaves. Using the context, every component knows
  # all its parents and can relate to them. It also contains a reference
  # to the global {Cache} instance.
  class Context
    attr_accessor :object_path, :file_path, :opts, :url, :mountpoint, :cache

    def initialize
      @object_path = []
      @file_path = []
    end

    def clone
      c = super
      c.object_path = c.object_path.clone
      c.file_path = c.file_path.clone
      c
    end

    def set(name, value)
      @object_path << [name, value]
    end

    def []=(name, value)
      set(name, value)
    end

    def [](name)
      item = @object_path.reverse.detect { |v| v[0] == name }
      item && item[1]
    end

    def last
      @object_path.last[1]
    end

    def method_missing(name, *args)
      self[name] || super
    end
  end
end
