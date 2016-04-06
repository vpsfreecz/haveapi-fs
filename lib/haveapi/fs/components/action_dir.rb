module HaveAPI::Fs::Components
  class ActionDir < Directory
    attr_reader :resource, :action
    children_reader :status, :input, :output

    def initialize(resource, action)
      super()
      
      @resource = resource
      @action = action

      setup
    end

    def setup
      children[:status] = ActionStatus.new(self)
      children[:input] = ActionInput.new(self)
      children[:output] = ActionOutput.new(self)
      children[:exec] = ActionExec.new(self)
      children[:reset] = ActionReset.new(self)
    end

    def contents
      %w(input output status exec reset) + help_contents
    end

    def exec
      @action.provide_args(*@resource.prepared_args)
      ret = HaveAPI::Client::Response.new(
          @action,
          @action.execute(children[:input].values)
      )

      children[:status].set(ret.ok?)

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

      children[:output].data = res if ret.ok?

    rescue HaveAPI::Client::ActionFailed => e
      children[:status].failed

      puts "action failed, meh"
      p e.message
    end

    def reset
      drop_children
      setup
    end

    protected
    def new_child(name)
      if help_file?(name)
        help_file(name)

      else
        nil
      end
    end
  end
end
