module HaveAPI::Fs
  class ActionDir < Directory
    attr_reader :resource, :action, :status, :input, :output

    def initialize(resource, action)
      @resource = resource
      @action = action
      @status = ActionStatus.new(self)
      @input = ActionInput.new(self)
      @output = ActionOutput.new(self)
      @exec = ActionExec.new(self)

      super()
    end
    
    def find(name)
      case name
      when :input
        @input

      when :output
        @output

      when :status
        @status

      when :exec
        @exec

      else
        nil
      end
    end

    def contents
      %w(input output status exec)
    end

    def exec
      @action.provide_args(*@resource.prepared_args)
      ret = HaveAPI::Client::Response.new(
          @action,
          @action.execute(@input.values)
      )

      @status.set(ret.ok?)

      puts "got"
      p ret.ok?
      p ret.response

      case @action.output_layout
      when :object
        res = HaveAPI::Client::ResourceInstance.new(
            @resource.instance_variable_get('@client'),
            @resource.instance_variable_get('@api'),
            @resource,
            action: @action,
            response: ret,
        )

      when :object_list
        res = HaveAPI::Client::ResourceInstanceList.new(
            @resource.instance_variable_get('@client'),
            @resource.instance_variable_get('@api'),
            @resource,
            @action,
            ret,
        )

      else
        res = ret
      end

      @output.data = res if ret.ok?

    rescue HaveAPI::Client::ActionFailed => e
      @status.failed

      puts "action failed, meh"
      p e.message
    end
  end
end
