module HaveAPI::Fs::Components
  class Directory < HaveAPI::Fs::Component
    include HaveAPI::Fs::Help

    def directory?
      true
    end
  end
end
