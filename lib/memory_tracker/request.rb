module MemoryTracker
  class Request
    include Sys

    attr_reader :start_gcstat, :end_gcstat
    attr_reader :gcstat_delta

    def initialize(env)
      @env         = env
      @start_gcstat = GcStat.new(self.class.rss, self.class.vsize)
    end

    def close
      @end_gcstat   = GcStat.new(self.class.rss, self.class.vsize)
      @gcstat_delta = GcStatDelta.new(@start_gcstat, @end_gcstat)
      self
    end

    def controller
      request[:controller]
    end

    def action
      request[:action]
    end

    def path
      @env['PATH_INFO']
    end

    private

    def request
      return @request if @request
      routes_env = { :method => @env['REQUEST_METHOD'] }
      @request = Rails.application.routes.recognize_path(env['REQUEST_URI'], routes_env)
    end

    def self.rss
      rss = ProcTable.ps(Process.pid).rss * 0.004096
    end

    def self.vsize
      vsize = ProcTable.ps(Process.pid).vsize * 0.000001
    end
  end
end
