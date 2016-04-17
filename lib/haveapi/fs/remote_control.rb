module HaveAPI::Fs
  # The purpose of this class is to handle commands received via the
  # {Components::RemoteControlFile}.
  class RemoteControl
    # Call method #exec of a component at `path`.
    #
    # @param [Context] context
    # @param [String] path
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
