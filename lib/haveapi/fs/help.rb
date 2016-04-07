module HaveAPI::Fs
  module Help
    protected
    def help_files
      %i(html).map { |v| :"help.#{v}" }
    end

    def help_contents
      help_files.map(&:to_s)
    end

    def help_file?(name)
      help_files.include?(name)
    end

    def help_file(name)
      format = name.to_s.split('.').last
      Components::HelpFile.new(self, format.to_sym)
    end
  end
end
