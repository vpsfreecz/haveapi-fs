module HaveAPI::Fs
  class RemoteControl
    def self.execute(context, path)
      c = context.fs.send(:find_component, path)

      unless c.is_a?(Components::ActionExec)
        raise RuntimeError, "'#{c.class}' cannot be executed"
      end

      ret = c.exec

      case ret
      when HaveAPI::Client::Response
        {status: ret.ok?, message: ret.message, errors: ret.errors}

      when HaveAPI::Client::ValidationError
        {status: false, message: ret.message, errors: ret.errors}

      else
        {status: false, message: 'unknown response'}
      end
    end
  end
end
