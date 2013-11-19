module MemoryTracker
  module Stores
    module Loader
      mattr_accessor :store_classes

      def self.register_store(name, klass)
        self.store_classes ||= {}
        store_classes[name] = klass
      end

      def self.add_store(memory_tracker, opts)
        klass = store_classes.fetch(opts[:name].to_sym) { raise "unknown store: #{opts[:name]}" }
        store = klass.new(opts)
        memory_tracker.add_store(store)
      end
    end
  end
end

require_relative 'in_memory_store'
require_relative 'url_logfile_store'
require_relative 'gcstat_logfile_store'

