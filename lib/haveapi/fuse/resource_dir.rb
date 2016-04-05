module HaveAPI::Fuse
  class ResourceDir < Component
    def initialize(resource)
      super()
      @resource = resource
      @index = find(:actions).find(:index)
    end

    def directory?
      true
    end

    def contents
      unless @data
        @index.exec
        @data = @index.output.data
      end

      %w(actions) + subresources.map(&:to_s) + @data.map { |v| v.id.to_s }
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
          # The directory contents have not been loaded yet. We should not load.
          # We don't necessarily need to load it all, a single query should be
          # sufficient.
          begin
            obj = @resource.show(id)
            ResourceInstanceDir.new(obj)

          rescue HaveAPI::Client::ActionFailed
            # Not found
          end
        end

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
  end
end
