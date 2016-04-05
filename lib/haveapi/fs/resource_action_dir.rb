module HaveAPI::Fs
  class ResourceActionDir < Directory
    def initialize(r)
      @resource = r
      @instance = r.is_a?(HaveAPI::Client::ResourceInstance)

      super()
    end

    def contents
      relevant_actions.map(&:to_s)
    end

    protected
    def new_child(name)
      ActionDir.new(@resource, @resource.actions[name])
    end

    def relevant_actions
      return @actions if @actions
      @actions = []

      @resource.actions.each do |name, a|
        pos = a.url.index(":#{@resource._name}_id")

        if @instance
          cond = pos

        else
          cond = pos.nil?
        end

        @actions << name if cond
      end

      @actions
    end
  end
end
