$:.insert(0, '/home/aither/workspace/vpsfree.cz/dev1.orion/haveapi-client/lib')

require 'rfusefs'
require 'haveapi/client'

module HaveAPI::Fs
  class Fs
    attr_reader :api

    def initialize(opts)
      @opts = opts
      p @opts

      @api = HaveAPI::Client::Client.new(
          @opts[:api],
          @opts[:version],
          identity: 'haveapi-fs'
      )
      @api.authenticate(
          @opts[:auth_method].to_sym,
          user: @opts[:username],
          password: @opts[:password],
      )
      @api.setup

      @path_cache = Cache.new
      @context = Context.new
      @context.url = @opts[:api]
      @context.mountpoint = ::File.realpath(@opts[:mountpoint])
      @context[:fs] = self

      @check_file = FuseFS::Fuse::Root::CHECK_FILE[1..-1].to_sym
      @root = Components::Root.new
      @root.context = @context.clone
      @root.context[:root] = @root
      @root.setup
    end

    def contents(path)
      puts "contents"
      p path

      guard { find_component(path).contents }
    end

    def directory?(path)
      puts "directory?"
      p path
    
      guard { find_component(path).directory? }
    end

    def file?(path)
      puts "file?"
      p path
    
      guard {find_component(path).file? }
    end

    def can_read?(path)
      puts "can_read?"
      p path

      guard { find_component(path).readable? }
    end

    def can_write?(path)
      puts "can_write?"
      p path

      guard { find_component(path).writable? }
    end

    def executable?(path)
      puts "executable?"
      p path

      guard { find_component(path).executable? }
    end

    def times(path)
      puts "times"
      p path

      guard { find_component(path).times }
    end

    def size(path)
      puts "size"
      p path
    
      guard { find_component(path).size }
    end

    def read_file(path)
      puts "read_file"
      p path
    
      guard { find_component(path).read }
    end

    def write_to(path, str)
      puts "write_to"
      p path

      guard { find_component(path).write(str) }
    end

    def raw_open(path, *args)
      puts "raw_open"
      p path

      guard { find_component(path).raw_open(path, *args) }
    end

    def raw_read(path, *args)
      puts "raw_read"
      p path

      guard { find_component(path).raw_read(path, *args) }
    end

    def raw_write(path, *args)
      puts "raw_write"
      p path

      guard { find_component(path).raw_write(path, *args) }
    end

    def raw_sync(path, *args)
      puts "raw_sync"
      p path

      guard { find_component(path).raw_sync(path, *args) }
    end

    def raw_truncate(path, *args)
      puts "raw_truncate"
      p path

      guard { find_component(path).raw_truncate(path, *args) }
    end
    
    def raw_close(path, *args)
      puts "raw_close"
      p path

      guard { find_component(path).raw_close(path, *args) }
    end

    protected
    def find_component(path)
      @path_cache.get(path) do
        t = Time.now

        names = path.split('/').map { |v| v.to_sym }[1..-1]
        tmp = @root

        next(tmp) unless names

        names.each do |n|
          if n === @check_file
            tmp = Components::RFuseCheck.new
            break

          else
            tmp = tmp.find(n)
          end
          
          if tmp.nil?
            raise Errno::ENOENT, "'#{path}' not found"

          else
            tmp.atime = t
          end
        end

        next(tmp)
      end
    end

    def guard
      yield

    rescue => e
      raise e if e.is_a?(::SystemCallError)

      warn "Exception #{e.class}"
      warn e.backtrace.join("\n")
      warn e.message

      raise Errno::EIO, e.message
    end
  end
end
