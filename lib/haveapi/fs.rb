module HaveAPI
  module Fs
    def self.new(*args)
      HaveAPI::Fs::Fs.new(*args)
    end
  end
end

require_relative 'fs/fs'
require_relative 'fs/context'
require_relative 'fs/cache'
require_relative 'fs/component'
require_relative 'fs/help'
require_relative 'fs/remote_control'
require_relative 'fs/version'
require_relative 'fs/components/directory'
require_relative 'fs/components/file'
require_relative 'fs/components/executable'
require_relative 'fs/components/remote_control_file'
require_relative 'fs/components/root'
require_relative 'fs/components/resource_dir'
require_relative 'fs/components/index_filter'
require_relative 'fs/components/resource_instance_dir'
require_relative 'fs/components/save_instance'
require_relative 'fs/components/resource_action_dir'
require_relative 'fs/components/action_dir'
require_relative 'fs/components/create_action_dir'
require_relative 'fs/components/action_input'
require_relative 'fs/components/action_output'
require_relative 'fs/components/list_item'
require_relative 'fs/components/action_status'
require_relative 'fs/components/action_message'
require_relative 'fs/components/action_errors'
require_relative 'fs/components/action_exec'
require_relative 'fs/components/action_reset'
require_relative 'fs/components/parameter'
require_relative 'fs/components/resource_id'
require_relative 'fs/components/help_file'
require_relative 'fs/components/instance_create'
require_relative 'fs/components/instance_edit'
require_relative 'fs/components/meta_dir'
require_relative 'fs/components/meta_file'
require_relative 'fs/components/rfuse_check'
