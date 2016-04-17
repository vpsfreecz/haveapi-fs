module HaveAPI::Fs::Components
  class ActionDir < Directory
    component :action_dir
    attr_reader :resource, :action
    children_reader :status, :input, :output

    def initialize(resource, action)
      super()
      
      @resource = resource
      @action = action
    end

    def setup
      super

      children[:status] = [ActionStatus, self, bound: true]
      children[:message] = [ActionMessage, self, bound: true]
      children[:errors] = [ActionErrors, self, bound: true]
      children[:input] = [ActionInput, self, bound: true]
      children[:output] = [ActionOutput, self, bound: true]
      children[:exec] = [ActionExec, self, bound: true]
      children[:reset] = [DirectoryReset, bound: true]
    end

    def contents
      ret = super + %w(input output status message errors exec reset)
      ret << 'exec.yml' if @action.input_params.any?
      ret
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

    protected
    def new_child(name)
      if child = super
        child

      elsif name == :'exec.yml' && @action.input_params.any?
        [ActionExecEdit, self]

      else
        nil
      end
    end
  end
end
