module HaveAPI::Fs::Components
  class ResourceInstanceDir < ResourceDir
    def setup
      super
     
      @show = use(:actions, :show)
      @update = use(:actions, :update)
      children[:save] = SaveInstance.new(self, bound: true) if @update

      # Disable object listing from ResourceDir.contents
      @index = false
    end

    def contents
      ret = super
      ret.concat(subresources.map(&:to_s))
      ret.concat(attributes)
      ret.concat(%w(save edit.yml)) if @update
      ret
    end

    def save
      ret = @update.exec
      self.mtime = Time.now
      ret
    end

    def replace_association(name, id)
      return unless children.has_key?(name)

      children[name].invalidate
      context.cache.drop_below(path)

      @resource.send("#{name}_id=", id)
      children[name] = setup_child(name, ResourceInstanceDir.new(@resource.send(name)))
    end

    def update_association(name)
      children[name].invalidate
      context.cache.drop_below(path)

      children[name] = setup_child(name, ResourceInstanceDir.new(@resource.send(name)))
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

    def attributes
      ret = []
      params = @resource.actions[:show].params

      @resource.attributes.each do |k, v|
        next if k == :_meta

        if params[k][:type] == 'Resource'
          ret << "#{k}_id"
          ret << k.to_s if v

        else
          ret << k.to_s
        end
      end

      ret
    end

    def title
      "#{@resource._name.to_s.capitalize} ##{@resource.id}"
    end

    protected
    def new_child(name)
      if child = super
        child
      
      elsif name == :actions
        ResourceActionDir.new(@resource)

      elsif subresources.include?(name)
        ResourceDir.new(@resource.send(name))

      elsif @resource.attributes.has_key?(name)
        if @show.action.params[name][:type] == 'Resource'
          instance = @resource.send(name)

          if instance
            ResourceInstanceDir.new(instance)

          else
            nil
          end

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

      elsif name.to_s.end_with?('_id')
        real_name = name[0..-4].to_sym
        return nil unless @resource.attributes.has_key?(real_name)

        editable = @update.nil? ? false : @update.action.input_params.has_key?(real_name)

        ResourceId.new(
            self,
            @resource.actions[:show],
            real_name,
            :output,
            @resource,
            editable: editable,
            mirror: editable && @update.find(:input).find(real_name),
        )

      elsif name == :'edit.yml'
        InstanceEdit.new(self)

      else
        nil
      end
    end
  end
end
