module HaveAPI::Fs::Auth
  # Base class for all authentication methods.
  class Base
    def self.method_name
      @method_name
    end

    # All authentication providers must register using this method.
    # @param [Symbol] name
    def self.register(name)
      HaveAPI::Fs.register_auth(name, self)
      @method_name = name
    end
    
    # Check if this authentication provider should be used based on `opts`.
    # @param [Hash] opts mount options
    def self.use?(opts)
      false
    end

    # @param [Hash] cfg server config
    # @param [Hash] opts mount options
    def initialize(cfg, opts)
      @cfg = cfg
      @opts = opts

      setup
    end

    # Called right after {#initialize}.
    def setup

    end

    def name
      self.class.method_name
    end

    # In this method, the provider should check if it has all needed
    # information. Missing pieces can be queried from the user on stdin.
    def validate

    end

    # Authenticate the `client` object
    # @param [HaveAPI::Client::Client] client
    def authenticate(client)
      
    end

    # Check whether the authentication works by running some real API request.
    def check(client)
      client.user.current
    end
  end
end
