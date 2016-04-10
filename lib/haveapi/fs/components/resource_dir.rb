module HaveAPI::Fs::Components
  class ResourceDir < Directory
    attr_reader :resource

    def initialize(resource)
      super()
      @resource = resource
    end

    def setup
      super
      @index = find(:actions).find(:index)
    end

    def contents
      load_contents if @index && (!@data || @refresh)

      ret = %w(actions) + subresources.map(&:to_s)
      ret.concat(@data.map { |v| v.id.to_s }) if @data
      ret << 'create.yml'
      ret.concat(help_contents)

      if @index
        ret.concat(@index.action.input_params.keys.map { |v| "by-#{v}" })
      end

      ret
    end

    def refresh
      @refresh = true
    end

    def delete(id)
      return unless @data
      i = @data.index { |v| v.id == id }
      @data.delete_at(i) if i
    end

    def title
      "Resource #{@resource._name.to_s.capitalize}"
    end

    protected
    def new_child(name)
      if name == :actions
        ResourceActionDir.new(@resource)

      elsif subresources.include?(name)
        ResourceDir.new(@resource.send(name))

      elsif /^\d+$/ =~ name
        id = name.to_s.to_i

        if @data
          r = @data.detect { |v| v.id == id }
          ResourceInstanceDir.new(r) if r

        else
          # The directory contents have not been loaded yet. We don't necessarily
          # need to load it all, a single query should be sufficient.
          begin
            obj = @resource.show(id, meta: meta_params)
            ResourceInstanceDir.new(obj)

          rescue HaveAPI::Client::ActionFailed
            # Not found
          end
        end

      elsif name == :'create.yml'
        InstanceCreate.new(self)

      elsif help_file?(name)
        help_file(name)

      elsif @index && name.to_s.start_with?('by-')
        by_param = name.to_s[3..-1].to_sym
        return nil unless @index.action.input_params.has_key?(by_param)

        IndexFilter.new(self, by_param)

      else
        nil
      end
    end

    def subresources
      return @subresources if @subresources
      @subresources = []

      @resource.resources.each do |r_name, r|
        r.actions.each do |a_name, a|
          if a.url.index(":#{@resource._name}_id").nil?
            @subresources << r_name
            break
          end
        end
      end

      @subresources
    end

    def meta_params
      {
          includes: @resource.actions[:show].params.select do |n, p|
            p[:type] == 'Resource'
          end.map do |n, p|
            n
          end.join(',')
      }
    end

    def load_contents
      @index.exec(meta: meta_params)
      new_data = @index.output.data

      if @data
        current_map = id_map(@data)
        res = []

        new_data.each do |v|
          if current_map.has_key?(v.id)
            # TODO: if old object is not modified, use the new object instead
            res << current_map[v.id]

          else
            res << v
          end
        end

        @data = res

      else
        @data = new_data
      end

      @refresh = false
    end

    def id_map(list)
      ret = {}
      list.each { |v| ret[v.id] = v }
      ret
    end
  end
end
