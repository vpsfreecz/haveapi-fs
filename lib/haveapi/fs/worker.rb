require 'thread'

module HaveAPI::Fs
  # Base class for classes that perform some regular work in a separate thread.
  class Worker
    attr_reader :runs

    # @param [HaveAPI::Fs::Fs] fs
    def initialize(fs)
      @fs = fs
      @run = true
      @pipe_r, @pipe_w = IO.pipe
      @runs = 0
      @mutex = Mutex.new
    end

    # Start the work thread.
    def start
      @thread = Thread.new do
        @mutex.synchronize { @next_time = Time.now + start_delay }
        wait(start_delay)

        while @run do
          @fs.synchronize { work }

          @runs += 1
          @mutex.synchronize do
            @last_time = Time.now
            @next_time = @last_time + work_period
          end

          wait(work_period)
        end
      end
    end

    # Stop and join the work thread.
    def stop
      @run = false
      @pipe_w.write('CLOSE')
      @thread.join

      @pipe_r.close
      @pipe_w.close
    end

    # The time when the work method was last run.
    def last_time
      @mutex.synchronize { @last_time }
    end

    # The time when the work method will be run next.
    def next_time
      @mutex.synchronize { @next_time }
    end

    protected
    def wait(n)
      IO.select([@pipe_r], [], [], n)
    end

    # @return [Integer] number of seconds to wait before the first work
    def start_delay
      raise NotImplementedError
    end

    # @return [Integer] number of seconds to wait between working
    def work_period
      raise NotImplementedError
    end
    
    # This method is regularly called to perform the work.
    def work
      raise NotImplementedError
    end
  end
end
