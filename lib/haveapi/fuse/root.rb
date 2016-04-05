module HaveAPI::Fuse
  class Root < Directory
    def initialize(api)
      super()
      @api = api
    end

    def contents
      @api.resources.keys.map(&:to_s)
    end

    protected
    def new_child(name)
      ResourceDir.new(@api.resources[name])
    end
  end
end
