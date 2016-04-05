module HaveAPI
  module Fs
    def self.new(*args)
      HaveAPI::Fs::Fs.new(*args)
    end
  end
end

require_relative 'fs/fs'
require_relative 'fs/cache'
require_relative 'fs/component'
require_relative 'fs/components/directory'
require_relative 'fs/components/file'
require_relative 'fs/components/root'
require_relative 'fs/components/resource_dir'
require_relative 'fs/components/resource_instance_dir'
require_relative 'fs/components/resource_action_dir'
require_relative 'fs/components/action_dir'
require_relative 'fs/components/action_input'
require_relative 'fs/components/action_output'
require_relative 'fs/components/list_item'
require_relative 'fs/components/action_status'
require_relative 'fs/components/action_exec'
require_relative 'fs/components/parameter'
require_relative 'fs/components/rfuse_check'