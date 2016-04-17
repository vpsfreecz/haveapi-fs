module HaveAPI::Fs::Components
  # Base class for all executables. Executables can be executed either by
  # writing `1` into them or by running them, as they contain a Ruby script.
  #
  # The Ruby script communicates with the file system using {RemoteControlFile}.
  # In short, it tells the file system to execute a component at a certain path,
  # which results in the same action as when `1` is written to the file.
  #
  # In both cases, the file system itself does the operation, the outer process
  # only signals it to do so and then waits for a reply.
  #
  # When the component is to be executed, method {#exec} is called.
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
      exec if str.strip == '1'
    end

    def exec
      raise NotImplementedError
    end
  end
end
