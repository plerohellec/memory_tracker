module MemoryTracker
  class Engine < ::Rails::Engine
    isolate_namespace MemoryTracker

    engine_base_dir = File.expand_path("../../..",     __FILE__)
    app_base_dir    = File.expand_path("../../../app", __FILE__)
    lib_base_dir    = File.expand_path("../../../lib", __FILE__)
    config_base_dir = File.expand_path("../../../config", __FILE__)

    config.autoload_paths << lib_base_dir


    initializer "memory_tracker.load_config" do |app|
      app_config_file_path = "#{app.root}/config/memory_tracker.yml"
      gem_config_file_path = "#{config_base_dir}/memory_tracker.yml"
      if File.exist?(app_config_file_path)
        config_file_path = app_config_file_path
      elsif File.exist?(gem_config_file_path)
        config_file_path = gem_config_file_path
      end

      if config_file_path
        Rails.logger.debug "Reading #{config_file_path}"
        config = YAML.load_file(config_file_path)
        config = config.fetch(Rails.env) { raise "#{Rails.env} environment key is missing from #{config_file_path}" }
        MemoryTracker.instance.config = ActiveSupport::HashWithIndifferentAccess.new(config)
      end
    end

    initializer "memory_tracker.add_middleware" do |app|
      app.middleware.use MemoryTracker::Middleware
    end

    initializer "memory_tracker.setup_stores" do |app|
      if MemoryTracker.instance.config
        MemoryTracker.instance.config[:stores].each do |store|
          Stores::Loader.enable_store(MemoryTracker.instance, store)
        end
      else
        Stores::Loader.enable_all(MemoryTracker.instance)
      end
    end
  end
end
