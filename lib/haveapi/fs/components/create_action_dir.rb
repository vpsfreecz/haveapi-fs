module HaveAPI::Fs::Components
  class CreateActionDir < ActionDir
    def exec
      ret = super
      
      if ret.is_a?(HaveAPI::Client::Response) && ret.ok?
        context[:resource_dir].refresh
      end

      ret
    end
  end
end
