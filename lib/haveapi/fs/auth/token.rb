require 'highline/import'

module HaveAPI::Fs::Auth
  class Token < Base
    register :token

    def self.use?(opts)
      opts[:token]
    end

    def setup
      @user = @opts[:user] || @cfg[:user]
      @passwd = @opts[:password] || @cfg[:password]
      @token = @opts[:token] || @cfg[:token]
    end

    def validate
      return if @token

      @user ||= ask('User name: ') { |q| q.default = nil }.to_s

      @passwd ||= ask('Password: ') do |q|
        q.default = nil
        q.echo = false
      end.to_s
    end

    def authenticate(client)
      if @token
        opts = {token: @token}

      else
        opts = {user: @user, password: @passwd}
      end

      client.authenticate(:token, opts)
    end
  end
end
