require 'uri'
require 'yaml'

module HaveAPI::Fs
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


  def self.register_auth(name, klass)
    @auth_methods ||= {}
    @auth_methods[name] = klass
  end

  def self.auth_method(opts, default)
    return @auth_methods[opts[:auth_method].to_sym] if opts[:auth_method]

    @auth_methods.each_value do |m|
      return m if m.use?(opts)
    end

    default ? @auth_methods[default] : @auth_methods.values.first
  end

  def self.read_config
    config_path = "#{Dir.home}/.haveapi-client.yml"

    if File.exists?(config_path)
      YAML.load_file(config_path)

    else
      nil
    end
  end

  def self.server_config(url)
    cfg = read_config
    return nil if cfg.nil? || cfg[:servers].nil?

    cfg[:servers].detect { |s| s[:url] == url }
  end

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

  def self.main(options = OPTIONS, usage = USAGE)
    FuseFS.main(ARGV, OPTIONS, USAGE, 'api_url') do |opts|
      fail "provide argument 'api_url'" unless opts[:device]

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

      HaveAPI::Fs.new(client, opts)
    end
  end
end
