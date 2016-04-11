require 'thread'

module HaveAPI::Fs
  class Cleaner < Worker
    # Delete components not accessed in the last 10 minutes
    ATIME = 10*60
    
    # Delete components created more than 30 minutes ago
    CTIME = 30*60

    def initialize(fs, root)
      super(fs)
      @root = root
      @sweep_id = true
    end

    def start_delay
      ATIME + 30
    end

    def work_period
      ATIME / 2
    end

    def work
      t = Time.now
      @atime = t - ATIME
      @ctime = t - CTIME

      sweep(@root)
      @sweep_id = !@sweep_id
    end

    def sweep(component)
      component.send(:children).delete_if do |_, c|
        sweep(c) unless c.file?

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
