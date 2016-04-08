module HaveAPI::Fs::Components
  class SaveInstance < File
    def initialize(resource_dir)
      super()
      @resource_dir = resource_dir
    end

    def writable?
      true
    end

    def read
      i = 0
      context.path.each do |k, v|
        puts "  #{i}. #{k} = #{v.class}"
        i += 1
      end
      ''
    end

    def write(str)
      return unless str.strip == '1'

      @resource_dir.save
    end
  end
end
