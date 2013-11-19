module MemoryTracker
  class Engine < ::Rails::Engine
    isolate_namespace MemoryTracker

    engine_base_dir = File.expand_path("../../..",     __FILE__)
    app_base_dir    = File.expand_path("../../../app", __FILE__)
    lib_base_dir    = File.expand_path("../../../lib", __FILE__)

    config.autoload_paths << lib_base_dir


    initializer "memory_tracker.load_config" do |app|
      config_file_path = "#{app.root}/config/memory_tracker.yml"
      if File.exist?(config_file_path)
        config = YAML.load_file(config_file_path)
        config = config.fetch(Rails.env) { raise "#{Rails.env} environment key is missing from #{config_file_path}" }
        MemoryTracker.instance.config = ActiveSupport::HashWithIndifferentAccess.new(config)
      end
    end

    initializer "memory_tracker.add_middleware" do |app|
      app.middleware.use MemoryTracker::Middleware
    end

    initializer "memory_tracker.setup_stores" do |app|
      MemoryTracker.instance.config[:stores].each do |store|
        Stores::Loader.add_store(MemoryTracker.instance, store)
      end
    end
  end
end
