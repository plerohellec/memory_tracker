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

    GCSTAT_LOGFILE = "#{Rails.root}/log/gcstat.log"

    initializer "memory_tracker.setup_stores" do |app|
      MemoryTracker.instance.gcstat_logger = ActiveSupport::CustomLogger.new(GCSTAT_LOGFILE)
      MemoryTracker.instance.add_store(LiveStore::Manager.new)
    end
  end
end

