require 'yaml'

module HaveAPI::Fs::Components
  class RemoteControlFile < File
    MSG_DELIMITER = "\nMSG_OVER\n"

    class FileHandle
      attr_accessor :read_buf
      attr_accessor :write_buf

      def initialize
        @read_buf = ''
        @write_buf = ''
      end

      def read(offset, size)
        @read_buf[offset, size]
      end

      def write(offset, size, buf)
        @write_buf[offset, size] = buf
      end

      def complete?
        @write_buf.end_with?(MSG_DELIMITER)
      end

      def parse
        cmd = YAML.load(@write_buf[0..(-1 - MSG_DELIMITER.size)])
        @write_buf.clear
        cmd
      end
    end

    def writable?
      true
    end

    def size
      # The size limits the maximum amount of data that can be read from this file
      4096
    end

    def raw_open(path, mode, rfusefs = nil)
      FileHandle.new
    end

    def raw_read(path, offset, size, handle = nil)
      handle.read(offset, size)
    end

    def raw_write(path, offset, size, buf, handle = nil)
      handle.write(offset, size, buf)

      if handle.complete?
        cmd = handle.parse

        case cmd[:action]
        when :execute
          ret = HaveAPI::Fs::RemoteControl.execute(context, cmd[:path])

        else
          raise Errno::EIO, "unsupported action '#{cmd[:action]}'"
        end

        handle.read_buf = YAML.dump(ret)
      end

      size
    end

    def raw_sync(path, datasync, handle = nil)
      nil
    end

    def raw_truncate(path, offset, handle = nil)
      true
    end
    
    def raw_close(path, handle = nil)
      nil
    end
  end
end
