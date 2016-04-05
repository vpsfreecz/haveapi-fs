module HaveAPI::Fs::Components
  class ResourceInstanceDir < ResourceDir
    def initialize(*args)
      super(*args)

      @update = find(:actions).find(:update)
      children[:save] = SaveInstance.new(self) if @update
    end

    def contents
      ret = %w(actions)
      ret.concat(subresources.map(&:to_s))
      ret.concat(@resource.attributes.keys.map(&:to_s) - %w(_meta))
      ret << 'save' if @update
      ret
    end

    def save
      @update.exec
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
          editable = @update.nil? ? false : @update.action.input_params.has_key?(name)

          Parameter.new(
              @resource.actions[:show],
              name,
              :output,
              @resource,
              editable: editable,
              mirror: editable && @update.find(:input).find(name),
          )
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
