module HaveAPI::Fs::Components
  class UpdateActionDir < ActionDir
    def exec
      ret = super

      return ret if !ret.is_a?(HaveAPI::Client::Response) || !ret.ok?

      data = children[:output].data
      return ret unless data.is_a?(HaveAPI::Client::ResourceInstance)

      params = @resource.actions[:show].params
      attrs = @resource.attributes

      data.attributes.each do |k, v|
        next if %i(id _meta).include?(k) || !attrs.has_key?(k)

        if params[k][:type] == 'Resource'
          @resource.send("#{k}=", data.send(k))
          context[:resource_instance_dir].update_association(k)

        else
          @resource.send("#{k}=", v)
        end
      end

      ret
    end
  end
end
