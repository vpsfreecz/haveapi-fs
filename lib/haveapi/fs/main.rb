require 'highline/import'
require 'yaml'

module HaveAPI::Fs
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

  def self.main
    options = %i(api version auth_method user password token)
    usage = <<END
        api=URL                URL to the API server
        version=VERSION        API version to use
        auth_method=METHOD     Authentication method (basic, token, noauth)
        user                   Username
        password               Password
        token                  Authentication token
END

    FuseFS.main(ARGV, options, usage) do |opts|
      fail "set option 'api'" unless opts[:api]

      cfg = server_config(opts[:api])
      client = HaveAPI::Client::Client.new(
          opts[:api],
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

      HaveAPI::Fs.new(client, opts)
    end
  end
end
