module HaveAPI::Fs::Auth
  class NoAuth < Base
    register :noauth

    def check(client)
      # do nothing
    end
  end
end
