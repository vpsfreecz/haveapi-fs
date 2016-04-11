require 'yaml'

module HaveAPI::Fs::Components
  class InstanceEdit < ActionExecEdit
    def header
      <<END
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
    end

    def read
      ret = header + "\n"
      instance_dir = context[:resource_instance_dir]

      @action_dir.action.input_params.each do |name, p|
        if p[:type] == 'Resource'
          v = instance_dir.resource.attributes[name][ p[:value_id].to_sym ]

        else
          v = instance_dir.resource.attributes[name]
        end

        ret += "# #{p[:label]}; #{p[:type]}\n"
        ret += "# #{p[:description]}\n"
        ret += "# Defaults to '#{p[:default]}'\n" unless p[:default].nil?
        ret += "#{name}: #{v}\n\n"
      end

      ret
    end

    def save?(data)
      data.any?
    end

    def save
      context[:resource_instance_dir].save
    end
  end
end
