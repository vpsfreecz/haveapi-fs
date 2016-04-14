module HaveAPI::Fs::Components
  class ComponentList < File
    def read
      str = component_list.map do |c|
        sprintf('%-50s %s', c.class.name, c.path)
      end.join("\n")
      str += "\n" unless str.empty?
      str
    end

    protected
    def component_list(component = nil)
      component ||= parent
      ret = []

      component.send(:children).each do |_, c|
        ret << c
        ret.concat(component_list(c))
      end

      ret
    end
  end
end
