module HaveAPI::Fs::Components
  class Executable < File
    def executable?
      true
    end

    def writable?
      true
    end

    def read
      abs_path = ::File.join(context.mountpoint, path)

      <<END
#!#{RbConfig.ruby}
#
# This action can be executed either by running this file or by writing "1" to
# it, e.g.:
#   
#   .#{abs_path}
#
# or
#
#   echo 1 > #{abs_path}
#
require 'yaml'

f = ::File.open(
    '#{::File.join(context.mountpoint, '.remote_control')}',
    'w+'
)
f.write(YAML.dump({
    action: :execute,
    path: '/#{path}',
}))
f.write(#{RemoteControlFile::MSG_DELIMITER.dump})
f.flush
f.seek(0)

ret = YAML.load(f.read)
f.close

unless ret[:status]
  warn "Action failed: \#{ret[:message]}"
  if ret[:errors]
    ret[:errors].each do |k, v|
      warn "  \#{k}: \#{v.join('; ')}"
    end
  end
end

exit(ret[:status])
END
    end

    def write(str)
      execute if str.strip == '1'
    end

    def exec
      raise NotImplementedError
    end
  end
end
