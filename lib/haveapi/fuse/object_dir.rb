module HaveAPI::Fuse
  class ObjectDir
    def initialize(obj)
      @obj = obj
    end

    def _name
      @obj._name
    end

    def id
      @obj.id
    end

    def object_actions

    end
  end
end
