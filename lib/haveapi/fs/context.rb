module HaveAPI::Fs
  class Context
    attr_accessor :path

    def initialize
      @path = []
    end

    def clone
      c = super
      c.path = c.path.clone
      c
    end

    def set(name, value)
      @path << [name, value]
    end

    def []=(name, value)
      set(name, value)
    end

    def last
      @path.last[1]
    end

    def method_missing(name, *args)
      item = @path.reverse.detect { |v| v[0] == name }
      item ? item[1] : super(name, *args)
    end
  end
end
