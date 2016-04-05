module HaveAPI::Fuse
  class Cache
    def initialize
      @cache = {}
    end

    def get(path, &block)
#      puts "cache.get #{path}"
#      @cache.each do |k,v|
#        puts "  #{k} = #{v.class}"
#      end
      #return block.call

      if @cache.has_key?(path)
        @cache[path]

      else
        @cache[path] = block.call
      end
    end

    def set(path, v)
      @cache[path] = v
    end
  end

  class ResourceCache < Cache
    def initialize(api)
      super()
      @api = api
    end

    def get(r, id, &block)
      super(path(r, id), &block)
    end

    def set(r, id, v)
      super(path(r, id), v)
    end

    protected
    def path(r, id)
      # FIXME: we need to store the entire resource name including its path,
      # as there can be many nested resources with the same name
      :"#{r._name}__#{id}"
    end
  end
end
