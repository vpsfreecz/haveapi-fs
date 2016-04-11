module HaveAPI::Fs::Components
  class ActionDir < Directory
    attr_reader :resource, :action
    children_reader :status, :input, :output

    def initialize(resource, action)
      super()
      
      @resource = resource
      @action = action
    end

    def setup
      super

      children[:status] = ActionStatus.new(self, bound: true)
      children[:message] = ActionMessage.new(self, bound: true)
      children[:errors] = ActionErrors.new(self, bound: true)
      children[:input] = ActionInput.new(self, bound: true)
      children[:output] = ActionOutput.new(self, bound: true)
      children[:exec] = ActionExec.new(self, bound: true)
      children[:reset] = DirectoryReset.new(bound: true)
    end

    def contents
      super + %w(input output status message errors exec reset)
    end

    def exec(meta: {})
      @action.provide_args(*@resource.prepared_args)
      ret = HaveAPI::Client::Response.new(
          @action,
          @action.execute(
              children[:input].values.update({meta: meta})
          )
      )

      children[:status].set(ret.ok?)

      if ret.ok?
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

        children[:output].data = res

      else
        children[:message].set(ret.message)
        children[:errors].set(ret.errors)
      end
      
      ret

    rescue HaveAPI::Client::ValidationError => e
      children[:status].set(false)
      children[:message].set(e.message)
      children[:errors].set(e.errors)
      e

    rescue HaveAPI::Client::ActionFailed => e
      children[:status].set(false)
      children[:message].set(e.response.message)
      children[:errors].set(e.response.errors)
      e.response
    end

    def title
      @action.name.capitalize
    end
  end
end
