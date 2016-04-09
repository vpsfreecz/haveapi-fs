require 'yaml'

module HaveAPI::Fs::Components
  class InstanceEdit < File
    def initialize(instance_dir)
      super()
      @instance_dir = instance_dir
      @update = @instance_dir.find(:actions).find(:update)
    end

    def writable?
      true
    end

    def read
      ret = <<END
# This file is in YAML format. Lines beginning with a hash (#) are comments and
# are ignored. The resource instance will be updated once this file is saved
# and closed. The success of this operation can be later checked in
# actions/update/status.
# 
# To avoid updating a parameter, simply comment or delete it from this file.
# Values of parameters that are not present when the file is closed are not
# changed.
#
# To cancel the update, either do not save the file or save it empty.

END

      @update.action.input_params.each do |name, p|
        if p[:type] == 'Resource'
          v = @instance_dir.resource.attributes[name][ p[:value_id].to_sym ]

        else
          v = @instance_dir.resource.attributes[name]
        end

        ret += "# #{p[:label]}; #{p[:type]}\n"
        ret += "# #{p[:description]}\n"
        ret += "# Defaults to '#{p[:default]}'\n" unless p[:default].nil?
        ret += "#{name}: #{v}\n\n"
      end

      ret
    end

    def write(str)
      return if str.strip.empty?

      data = YAML.load(str)
      raise Errno::EIO, 'invalid yaml document' unless data.is_a?(::Hash)
      return if data.empty?

      params = @update.action.input_params

      data.each do |k, v|
        p = @update.find(:input).find(k.to_sym)
        next if p.nil?

        # Type coercion is done later by the client during action call
        p.write_safe(v)
      end

      @instance_dir.save
    end
  end
end
