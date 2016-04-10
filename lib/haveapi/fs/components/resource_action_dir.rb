module HaveAPI::Fs::Components
  class ResourceActionDir < Directory
    attr_reader :resource

    def initialize(r)
      @resource = r
      @instance = r.is_a?(HaveAPI::Client::ResourceInstance)

      super()
    end

    def contents
      super + relevant_actions.map(&:to_s)
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

    def title
      'Actions'
    end

    protected
    def new_child(name)
      if child = super
        child
      
      elsif @resource.actions.has_key?(name)
        klass = case name
        when :create
          CreateActionDir

        when :update
          instance? ? UpdateActionDir : ActionDir

        when :delete
          DeleteActionDir

        else
          ActionDir
        end
        
        klass.new(@resource, @resource.actions[name])

      else
        nil
      end
    end
  end
end
