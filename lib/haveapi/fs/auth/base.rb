module HaveAPI::Fs::Auth
  class Base
    def self.method_name
      @method_name
    end

    def self.register(name)
      HaveAPI::Fs.register_auth(name, self)
      @method_name = name
    end
    
    def self.use?(opts)
      false
    end

    def initialize(cfg, opts)
      @cfg = cfg
      @opts = opts

      setup
    end

    def setup

    end

    def name
      self.class.method_name
    end

    def validate

    end

    def authenticate(client)
      
    end

    def check(client)
      client.user.current
    end
  end
end
