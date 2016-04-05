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
require_relative 'fs/directory'
require_relative 'fs/file'
require_relative 'fs/root'
require_relative 'fs/resource_dir'
require_relative 'fs/resource_instance_dir'
require_relative 'fs/resource_action_dir'
require_relative 'fs/action_dir'
require_relative 'fs/action_input'
require_relative 'fs/action_output'
require_relative 'fs/list_item'
require_relative 'fs/action_status'
require_relative 'fs/action_exec'
require_relative 'fs/parameter'
require_relative 'fs/rfuse_check'
