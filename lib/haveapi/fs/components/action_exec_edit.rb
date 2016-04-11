require 'yaml'

module HaveAPI::Fs::Components
  class ActionExecEdit < File
    def initialize(action_dir)
      super()
      @action_dir = action_dir
    end

    def writable?
      true
    end

    def read
      ret = header + "\n"

      @action_dir.action.input_params.each do |name, p|
        param_file = @action_dir.find(:input).find(name)

        if param_file.set?
          v = param_file.new_value
        
        elsif p[:default].nil?
          v = nil

        else
          v = p[:default]
        end

        ret += "# #{p[:label]}; #{p[:type]}\n"
        ret += "# #{p[:description]}\n"
        ret += "# Defaults to '#{p[:default]}'\n" unless p[:default].nil?

        if p[:required] || param_file.set?
          ret += "#{name}: #{v}"

        else
          ret += "##{name}: #{v}"
        end

        ret += "\n\n"
      end

      ret
    end

    def write(str)
      return if str.strip.empty?

      data = YAML.load(str)
      raise Errno::EIO, 'invalid yaml document' unless data.is_a?(::Hash)
      return unless save?(data)

      params = @action_dir.action.input_params

      data.each do |k, v|
        p = @action_dir.find(:input).find(k.to_sym)
        next if p.nil?

        # Type coercion is done later by the client during action call
        p.write_safe(v)
      end

      save
    end

    def header
      <<END
# This file is in YAML format. Lines beginning with a hash (#) are comments and
# are ignored. The action will be executed once this file is saved and closed.
# The success of this operation can be later checked in
# actions/#{@action_dir.action.name}/status.
# 
# Only required parameters that need to be set are uncommented by default.
# Parameters that are not specified when this file is closed will not be sent
# to the API.
#
# To cancel the operation, either do not save the file or save it empty.
END
    end

    def save?(data)
      true
    end

    def save
      @action_dir.exec
    end
  end
end
