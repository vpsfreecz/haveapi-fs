module HaveAPI::Fs
  class HashListWrapper < Array
    def initialize(client, api, resource, action, data)
      data.each do |v|
        self << HashWrapper.new(client, api, resource, action, v)
      end
    end

    def id
      @data[:id]
    end

    def [](k)
      @data[k]
    end

    def []=(k, v)
      @data[k] = v
    end
  end
end
