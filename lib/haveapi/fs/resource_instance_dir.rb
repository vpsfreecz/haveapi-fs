module HaveAPI::Fs
  class ResourceInstanceDir < ResourceDir
    def contents
      %w(actions) + subresources.map(&:to_s) + \
      (@resource.attributes.keys.map(&:to_s) - %w(_meta))
    end

    protected
    def new_child(name)
      if name == :actions
        ResourceActionDir.new(@resource)

      elsif subresources.include?(name)
        ResourceDir.new(@resource.send(name))

      elsif @resource.attributes.has_key?(name)
        if @index.action.params[name][:type] == 'Resource'
          ResourceInstanceDir.new(@resource.send(name))

        else
          Parameter.new(@resource.actions[:show], name, :output, @resource)
        end

      else
        nil
      end
    end

    def subresources
      return @subresources if @subresources
      @subresources = []

      @resource.resources.each do |r_name, r|
        r.actions.each do |a_name, a|
          if a.url.index(":#{@resource._name}_id")
            @subresources << r_name
            break
          end
        end
      end

      @subresources
    end
  end
end
