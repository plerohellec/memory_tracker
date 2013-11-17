$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "memory_tracker/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "memory_tracker"
  s.version = MemoryTracker::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Philippe Le Rohellec"]
  s.date = "2013-11-15"
  s.summary = "Rails memory allocations tracker"
  s.description = "Collect and analyze memory usage data for each individual Rails action controller."
  s.email = "philippe@lerohellec.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "app/controllers/memory_tracker/application_controller.rb",
    "app/controllers/memory_tracker/dashboards_controller.rb",
    "app/helpers/memory_tracker/dashboards_helper.rb",
    "app/views/layouts/memory_tracker.html.erb",
    "app/views/memory_tracker/dashboards/index.html.erb",
    "config/routes.rb",
    "lib/memory_tracker.rb",
    "lib/memory_tracker/engine.rb",
    "lib/memory_tracker/env.rb",
    "lib/memory_tracker/gc_stat.rb",
    "lib/memory_tracker/memory_tracker.rb",
    "lib/memory_tracker/middleware.rb",
    "lib/memory_tracker/request.rb",
    "lib/memory_tracker/stores/gcstat_logfile_store.rb",
    "lib/memory_tracker/stores/in_memory_store.rb",
    "lib/memory_tracker/stores/url_logfile_store.rb",
    "memory_tracker.gemspec"]
  s.test_files = Dir["spec/**/*"]

  s.homepage = "http://github.com/plerohellec/memory_tracker"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.0.3"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sys-proctable>, [">= 0"])
      s.add_development_dependency(%q<debugger>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.14.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])

    else
      s.add_dependency(%q<sys-proctable>, [">= 0"])
      s.add_dependency(%q<debugger>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2.14.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])

    end
  else
    s.add_dependency(%q<sys-proctable>, [">= 0"])
    s.add_dependency(%q<debugger>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2.14.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
  end
end
