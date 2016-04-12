require 'highline/import'

module HaveAPI::Fs
  def self.ask_credentials(user = nil, passwd = nil)
    user ||= ask('User name: ') { |q| q.default = nil }.to_s

    passwd ||= ask('Password: ') do |q|
      q.default = nil
      q.echo = false
    end.to_s

    [user, passwd]
  end

  def self.main
    options = %i(api version noauth username password token)
    usage = <<END
        api=URL                URL to the API server
        version=V              API version to use
        noauth                 Do not authenticate
        username               Username
        password               Password
        token                  Authentication token
END

    FuseFS.main(ARGV, options, usage) do |opts|
      fail "set option 'api'" unless opts[:api]

      client = HaveAPI::Client::Client.new(
          opts[:api],
          opts[:version],
          identity: 'haveapi-fs'
      )

      if opts[:noauth]
        # Skip authentication

      elsif opts[:token]
        client.authenticate(:token, token: opts[:token])

      else
        user, passwd = ask_credentials(opts[:username], opts[:password]) 
        client.authenticate(:basic, user: user, password: passwd)
      end

      # Fetch API description, must be done especially after authentication
      client.setup

      # Verify authentication
      client.user.current unless opts[:noauth]

      HaveAPI::Fs.new(client, opts)
    end
  end
end
