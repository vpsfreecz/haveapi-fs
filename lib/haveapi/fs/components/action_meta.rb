module HaveAPI::Fs::Components
  class ActionMeta < Directory
    component :action_meta
    
    def initialize(action_dir, *args)
      super(*args)
      @action_dir = action_dir
    end

    def setup
      super
      
      children[:input] = [MetaInput, @action_dir, bound: true]
      children[:output] = [MetaOutput, @action_dir, :global, bound: true]
    end

    def contents
      super + %w(output)
    end

    def output=(data)
      children[:output].data = data
    end

    def values
      children[:input].values
    end

    def title
      'Input/output global metadata parameters'
    end
  end
end
