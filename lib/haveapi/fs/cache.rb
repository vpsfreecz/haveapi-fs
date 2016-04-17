require 'thread'

module HaveAPI::Fs
  # A path-based cache for the component tree.
  class Cache < Worker
    attr_reader :hits, :misses, :invalid, :drops

    def initialize(fs)
      super
      @cache = {}
      @hits = 0
      @misses = 0
      @invalid = 0
      @drops = 0
    end

    def size
      @cache.size
    end

    # Find component with `path` in the cache. If the component is not in the
    # cache yet or is in an invalid state, `block` is called and its return
    # value is saved in the cache for this `path`.
    #
    # @param [String] path
    # @yieldreturn [HaveAPI::Fs::Component]
    def get(path, &block)
      obj = @cache[path]

      if obj
        if obj.invalid?
          @invalid += 1
          @cache[path] = block.call

        else
          @hits += 1
          obj
        end

      else
        @misses += 1
        @cache[path] = block.call
      end
    end

    def set(path, v)
      @cache[path] = v
    end

    # Drop the component at `path` and all its descendants from the cache.
    # @param [String] path
    def drop_below(path)
      abs_path = '/' + path
      keys = @cache.keys.select { |k| k.start_with?(abs_path) }
      @drops += keys.count
      keys.each { |k| @cache.delete(k) }
    end

    def start_delay
      Cleaner::ATIME + 60
    end

    def work_period
      Cleaner::ATIME / 2 + 60
    end

    def work
      @cache.delete_if { |k, v| v.invalid? }
    end
  end
end
