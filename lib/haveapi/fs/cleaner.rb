require 'thread'

module HaveAPI::Fs
  class Cleaner
    # Delete components not accessed in the last 10 minutes
    ATIME = 0.5*60
    
    # Delete components created more than 30 minutes ago
    CTIME = 1*60

    def initialize(fs, root)
      @fs = fs
      @root = root
      @sweep_id = true
      @run = true
      @pipe_r, @pipe_w = IO.pipe
    end

    def start
      @thread = Thread.new do
        wait(ATIME + 30)

        while @run do
          @fs.synchronize { sweep }
          wait(ATIME / 2)
        end
      end
    end

    def stop
      @run = false
      @pipe_w.write('CLOSE')
      @thread.join

      @pipe_r.close
      @pipe_w.close
    end

    def wait(n)
      IO.select([@pipe_r], [], [], n)
    end

    def sweep
      t = Time.now
      @atime = t - ATIME
      @ctime = t - CTIME

      sweep_inner(@root)
      @sweep_id = !@sweep_id
    end

    def sweep_inner(component)
      component.send(:children).delete_if do |_, c|
        sweep_inner(c) unless c.file?

        if !c.bound? && (c.ctime < @ctime || c.atime < @atime)
          if c.unsaved?(@sweep_id ? 1 : 0)
            puts "cannot free unsaved '#{c.path}'"
            next(false)

          else
            c.invalidate
            next(true)
          end
        end
      end
    end
  end
end
