module HaveAPI::Fs
  class Worker
    def initialize(fs)
      @fs = fs
      @run = true
      @pipe_r, @pipe_w = IO.pipe
    end

    def start
      @thread = Thread.new do
        wait(start_delay)

        while @run do
          @fs.synchronize { work }
          wait(work_period)
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
  end
end
