module MemoryTracker
  module Stores
    class Base
      class_attribute :name

      def self.register_store(name)
        self.name = name
        Loader.register_store(name, self)
      end

      def name
        self.class.name
      end
    end
  end
end
