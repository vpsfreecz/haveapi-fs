module HaveAPI::Fs
  class Cache
    def initialize
      @cache = {}
    end

    def get(path, &block)
      obj = @cache[path]

      if obj
        if obj.invalid?
          @cache[path] = block.call

        else
          obj
        end

      else
        @cache[path] = block.call
      end
    end

    def set(path, v)
      @cache[path] = v
    end

    def drop_below(path)
      abs_path = '/' + path
      @cache.keys.select { |k| k.start_with?(abs_path) }.each { |k| @cache.delete(k) }
    end
  end
end
