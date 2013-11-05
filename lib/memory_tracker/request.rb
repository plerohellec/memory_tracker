module MemoryTracker
  class Request
    include Sys

    attr_reader :start_gcstat, :end_gcstat
    attr_reader :gcstat_delta

    extend Forwardable
    def_delegators :@env, :path, :controller, :action

    def initialize(env)
      @env          = env
      @start_gcstat = GcStat.new(self.class.rss, self.class.vsize)
    end

    def close
      @end_gcstat   = GcStat.new(self.class.rss, self.class.vsize)
      @gcstat_delta = GcStatDelta.new(@start_gcstat, @end_gcstat)
      self
    end

    private

    def self.rss
      rss = ProcTable.ps(Process.pid).rss * 0.004096
    end

    def self.vsize
      vsize = ProcTable.ps(Process.pid).vsize * 0.000001
    end
  end

  class Env
    attr_reader :path, :controller, :action

    def initialize(env)
      @path = env['PATH_INFO']

      routes_env = { :method => env['REQUEST_METHOD'] }
      request = Rails.application.routes.recognize_path(env['REQUEST_URI'], routes_env)
      @controller = request[:controller]
      @action     = request[:action]
    end
  end
end
