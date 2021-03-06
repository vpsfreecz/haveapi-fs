module HaveAPI::Fs::Components
  class ActionOutput < Directory
    component :action_output
    attr_reader :action_dir
    attr_accessor :data

    def initialize(action_dir, *args)
      super(*args)

      @action_dir = action_dir

      if %i(hash_list object_list).include?(@action_dir.action.output_layout.to_sym)
        @list = true
      end
    end

    def contents
      ret = super

      return ret unless @data

      if @list
        ret.concat(@data.map { |v| v.id.to_s })

      else
        ret.concat(parameters.keys.map(&:to_s))
      end

      ret
    end

    def parameters
      @action_dir.action.params
    end

    def title
      'Output parameters'
    end

    protected
    def new_child(name)
      if child = super
        child
      
      elsif !@data
        nil

      elsif @list
        id = name.to_s.to_i
        
        if @data.is_a?(HaveAPI::Client::ResourceInstanceList)
          param = @data.detect { |v| v.id == id }
          [ResourceInstanceDir, param]

        else
          param = @data.response.detect { |v| v[:id] == id }
          [ListItem, @action_dir.action, :output, param]
        end

      elsif parameters.has_key?(name)
        [
            Parameter,
            @action_dir.action,
            name,
            :output,
            @data,
        ]

      else
        nil
      end
    end
  end
end
