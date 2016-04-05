require 'time'

module HaveAPI::Fuse
  class Parameter < Component
    def initialize(action, name, dir, value = nil, editable: nil)
      @action = action
      @name = name
      @dir = dir
      @value = value
      @set = false
      
      if dir == :input
        @params = @action.input_params

      else
        @params = @action.params
      end

      @desc = @params[@name]

      if editable.nil?
        @writable = dir == :input

      else
        @writable = editable
      end
    end

    def file?
      true
    end

    def writable?
      @writable
    end

    def read
      str = value.to_s
      str.empty? ? str : str + "\n"
    end

    def write(raw)
      @set = true
      str = raw.strip

      if str.empty?
        @new_value = nil
        return
      end

      @new_value = case @desc[:type]
      when 'Resource'
        str.to_i

      when 'Boolean'
        HaveAPI::Client::Parameters::Typed.Boolean.to_b(str)

      when 'Integer'
        str.to_i

      when 'Float'
        str.to_f

      when 'Datetime'
        Time.iso8601(str)

      else
        str.strip
      end
      
    rescue => e
      @set = false
      raise e
    end

    def value
      # Value in ResourceInstance
      # Value in hash
      # Value changed, saved in instance variable

      hash = @value.is_a?(::Hash)

      if @desc[:type] == 'Resource'
        return nil if @value.nil?
        @value.attributes[@name][@desc[:value_id].to_sym]

      else
        if @new_value
          v = @new_value

        else
          return nil if @value.nil?
            
          v = hash ? @value[@name] : @value.send(@name)
        end

        case @desc[:type]
        when 'Boolean'
          v ? 1 : 0

        when 'Datetime'
          v.is_a?(::Time) ? v.iso8601 : v

        else
          v
        end

      end
    end

    def set?
      @set      
    end
  end
end
