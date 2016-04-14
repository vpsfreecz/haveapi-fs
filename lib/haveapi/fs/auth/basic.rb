require 'highline/import'

module HaveAPI::Fs::Auth
  class Basic < Base
    register :basic

    def self.use?(opts)
      opts[:user] || opts[:password]
    end

    def setup
      @user = @opts[:user] || @cfg[:user]
      @passwd = @opts[:password] || @cfg[:password]
    end

    def validate
      @user ||= ask('User name: ') { |q| q.default = nil }.to_s

      @passwd ||= ask('Password: ') do |q|
        q.default = nil
        q.echo = false
      end.to_s
    end

    def authenticate(client)
      client.authenticate(:basic, user: @user, password: @passwd)
    end
  end
end
