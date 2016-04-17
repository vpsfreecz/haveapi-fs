require 'uri'
require 'yaml'

module HaveAPI::Fs
  # A list of accepted mount options
  OPTIONS = %i(api version auth_method user password token nodaemonize log
                index_limit)
  USAGE = <<END
    version=VERSION        API version to use
    auth_method=METHOD     Authentication method (basic, token, noauth)
    user                   Username
    password               Password
    token                  Authentication token
    nodaemonize            Stay in the foreground
    log                    Enable logging while daemonized
    index_limit=LIMIT      Limit number of objects in resource directory
END


  # Every authentication provider must register using this method.
  # @param [Symbol] name
  # @param [Class] klass
  def self.register_auth(name, klass)
    @auth_methods ||= {}
    @auth_methods[name] = klass
  end

  # Return authentication method based on mount options or return the default
  # one.
  # @param [Hash] opts mount options
  # @param [Symbol] default name of the default authentication method
  def self.auth_method(opts, default)
    return @auth_methods[opts[:auth_method].to_sym] if opts[:auth_method]

    @auth_methods.each_value do |m|
      return m if m.use?(opts)
    end

    default ? @auth_methods[default] : @auth_methods.values.first
  end

  # @return [Hash] if the config exists
  # @return [nil] if the config does not exist
  def self.read_config
    config_path = "#{Dir.home}/.haveapi-client.yml"

    if File.exists?(config_path)
      YAML.load_file(config_path)

    else
      nil
    end
  end

  # Return configuration of a particular server from the config hash.
  # @param [String] url URL of the API server
  def self.server_config(url)
    cfg = read_config
    return nil if cfg.nil? || cfg[:servers].nil?

    cfg[:servers].detect { |s| s[:url] == url }
  end

  # Perform a double-fork to make the process independent. Stdout and stderr
  # are redirected either to a log file or to /dev/null.
  #
  # @param [Hash] opts mount options
  def self.daemonize(opts)
    home = ::File.join(Dir.home, '.haveapi-fs', URI(opts[:device]).host)
    FileUtils.mkpath(home)
    
    pid = Process.fork

    if pid
      exit # Parent 1

    else
      pid = Process.fork
      exit if pid # Parent 2
    end

    # Only the child gets here
    STDIN.close
    
    f = File.open(
        opts[:log] ? File.join(home, 'haveapi-fs.log') : '/dev/null',
        'w'
    )

    STDOUT.reopen(f)
    STDERR.reopen(f)
  end

  # Create and setup an instance of HaveAPI::Client::Client based on the mount
  # options, calls self.daemonize if not configured otherwise.
  #
  # @param [Hash] opts mount options
  # @return [HaveAPI::Client::Client]
  def self.client(opts)
    cfg = server_config(opts[:device])
    client = HaveAPI::Client::Client.new(
        opts[:device],
        opts[:version],
        identity: 'haveapi-fs',
    )

    auth_klass = auth_method(opts, cfg && cfg[:last_auth])

    auth = auth_klass.new(
        (cfg && cfg[:auth][auth_klass.method_name]) || {},
        opts,
    )
    auth.validate
    auth.authenticate(client)

    # Fetch API description, must be done especially after authentication
    client.setup

    # Verify that authentication works
    auth.check(client)

    daemonize(opts) unless opts[:nodaemonize]
    client
  end

  # Calls FuseFS.main with an instance of {HaveAPI::Fs::Fs}.
  def self.main(options = OPTIONS, usage = USAGE)
    FuseFS.main(ARGV, OPTIONS, USAGE, 'api_url') do |opts|
      fail "provide argument 'api_url'" unless opts[:device]

      HaveAPI::Fs.new(client(opts), opts)
    end
  end
end
