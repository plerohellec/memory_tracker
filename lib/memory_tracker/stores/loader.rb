module MemoryTracker
  module Stores
    module Loader
      mattr_accessor :store_classes

      def self.register_store(name, klass)
        self.store_classes ||= {}
        store_classes[name] = klass
      end

      def self.enable_store(memory_tracker, opts)
        klass = store_classes.fetch(opts[:name].to_sym) { raise "unknown store: #{opts[:name]}" }
        store = klass.new(opts)
        memory_tracker.add_store(store)
      end

      def self.enable_all(memory_tracker)
        store_classes.each do |name, klass|
          store = klass.new({})
          memory_tracker.add_store(store)
        end
      end
    end
  end
end

store_filenames = Dir["#{File.expand_path('..', __FILE__)}/*_store.rb"]
store_filenames.each { |f| require f }

