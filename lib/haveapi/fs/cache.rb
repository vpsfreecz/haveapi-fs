require 'thread'

module HaveAPI::Fs
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
