require 'thread'

module HaveAPI::Fs
  class Cache < Worker
    def initialize(fs)
      super
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
