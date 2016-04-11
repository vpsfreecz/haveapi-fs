require 'yaml'

module HaveAPI::Fs::Components
  class InstanceCreate < ActionExecEdit
    def header
      <<END
# This file is in YAML format. Lines beginning with a hash (#) are comments and
# are ignored. The new resource instance will be created once this file is saved
# and closed. The success of this operation can be later checked in
# actions/create/status.
# 
# Only required parameters that need to be set are uncommented by default.
# Parameters that are not specified when this file is closed will not be sent
# to the API.
#
# To cancel the operation, either do not save the file or save it empty.
END
    end
  end
end
