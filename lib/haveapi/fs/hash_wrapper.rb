module HaveAPI::Fs
  class HashWrapper < HaveAPI::Client::Resource
    def initialize(client, api, resource, action, data)
      super(client, api, resource._name)
      setup(resource.instance_variable_get('@description'))

      @data = data
      @data.each do |k, v|
        define_singleton_method(k) { v }
      end
    end

    def attributes
      @data
    end

    def [](k)
      @data[k]
    end

    def []=(k, v)
      @data[k] = v
    end
  end
end
