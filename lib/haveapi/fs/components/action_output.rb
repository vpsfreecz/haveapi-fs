module HaveAPI::Fs::Components
  class ActionOutput < Directory
    attr_reader :action_dir
    attr_accessor :data

    def initialize(action_dir)
      super()

      @action_dir = action_dir

      if %i(hash_list object_list).include?(@action_dir.action.output_layout.to_sym)
        @list = true
      end
    end

    def contents
      ret = super

      return ret unless @data

      if @list
        if @data.is_a?(HaveAPI::Client::ResourceInstanceList)
          ret.concat(@data.map { |v| v.id.to_s })

        else
          ret.concat(@data.response.map { |v| v[:id].to_s })
        end

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
          ResourceInstanceDir.new(param)

        else
          param = @data.response.detect { |v| v[:id] == id }
          ListItem.new(@action_dir.action, :output, param)
        end

      elsif @action_dir.action.params.has_key?(name)
        Parameter.new(
            @action_dir.action,
            name,
            :output,
            @data.is_a?(HaveAPI::Client::ResourceInstance) ? @data : @data.response,
        )

      else
        bil
      end
    end
  end
end
