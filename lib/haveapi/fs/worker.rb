require 'thread'

module HaveAPI::Fs
  class Worker
    attr_reader :runs

    def initialize(fs)
      @fs = fs
      @run = true
      @pipe_r, @pipe_w = IO.pipe
      @runs = 0
      @mutex = Mutex.new
    end

    def start
      @thread = Thread.new do
        @mutex.synchronize { @next_time = Time.now + start_delay }
        wait(start_delay)

        while @run do
          @fs.synchronize { work }
          @runs += 1
          @mutex.synchronize { @next_time = Time.now + work_period }
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

    def next_time
      @mutex.synchronize { @next_time }
    end
  end
end
