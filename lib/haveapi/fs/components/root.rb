module HaveAPI::Fs::Components
  class Root < Directory
    def initialize(api)
      super()
      @api = api
    end

    def contents
      @api.resources.keys.map(&:to_s) + help_contents
    end

    def resources
      @api.resources
    end

    protected
    def new_child(name)
      if @api.resources.has_key?(name)
        ResourceDir.new(@api.resources[name])

      elsif help_file?(name)
        help_file(name)

      else
        nil
      end
    end
  end
end
