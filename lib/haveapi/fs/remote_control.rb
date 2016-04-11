module HaveAPI::Fs
  class RemoteControl
    def self.execute(context, path)
      c = context.fs.send(:find_component, path)

      ret = c.exec

      case ret
      when true
        {status: true}

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
