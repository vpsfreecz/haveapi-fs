module HaveAPI::Fs::Components
  class UnsavedList < File
    def read
      str = list_unsaved.join("\n")
      str += "\n" unless str.empty?
      str
    end

    protected
    def list_unsaved(component = nil)
      component ||= parent
      ret = []

      component.send(:children).each do |_, c|
        next unless c.unsaved?

        ret << c.path
        ret.concat(list_unsaved(c))
      end
      
      ret
    end
  end
end
