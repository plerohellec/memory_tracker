module MemoryTracker
  class Engine < Rails::Engine

    isolate_namespace MemoryTracker

    engine_base_dir = File.expand_path("../../..",     __FILE__)
    app_base_dir    = File.expand_path("../../../app", __FILE__)
    lib_base_dir    = File.expand_path("../../../lib", __FILE__)

    config.autoload_paths << lib_base_dir

    initializer "memory_tracker.add_middleware" do |app|
      app.middleware.use MemoryTracker::Middleware
    end

    initializer "memory_tracker.setup_stores" do |app|
      MemoryTracker.instance.add_store(Stores::GcstatLogfileStore.new(ActiveSupport::BufferedLogger, "#{Rails.root}/log/gcstat.log"))
      MemoryTracker.instance.add_store(Stores::InMemoryStore::Manager.new)
    end
  end
end

