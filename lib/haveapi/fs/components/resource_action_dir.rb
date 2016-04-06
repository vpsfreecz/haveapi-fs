module HaveAPI::Fs::Components
  class ResourceActionDir < Directory
    attr_reader :resource

    def initialize(r)
      @resource = r
      @instance = r.is_a?(HaveAPI::Client::ResourceInstance)

      super()
    end

    def contents
      relevant_actions.map(&:to_s) + help_contents
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

    def instance?
      @instance
    end

    protected
    def new_child(name)
      if @resource.actions.has_key?(name)
        ActionDir.new(@resource, @resource.actions[name])

      elsif help_file?(name)
        help_file(name)

      else
        nil
      end
    end
  end
end
