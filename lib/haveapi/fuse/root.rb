module HaveAPI::Fuse
  class Root < Component
    def initialize(api)
      super()
      @api = api
    end

    def directory?
      true
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
