module HaveAPI::Fs::Components
  class DeleteActionDir < ActionDir
    help_file :action_dir

    def exec
      ret = super
      
      if ret.is_a?(HaveAPI::Client::Response) && ret.ok?
        if @resource.is_a?(HaveAPI::Client::ResourceInstance)
          id = @resource.id

        else
          id = @resource.prepared_args.last
        end

        context[:resource_dir].delete(id)
      end

      ret
    end
  end
end
