module MemoryTracker
  class Request
    include Sys

    attr_reader :start_gcstat, :end_gcstat
    attr_reader :gcstat_delta

    def initialize(env)
      @env         = env
      @start_gcstat = GcStat.new(rss, vsize)
    end

    def close
      @end_gcstat   = GcStat.new(rss, vsize)
      @gcstat_delta = GcStatDelta.new(@start_gcstat, @end_gcstat)
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

    def rss
      rss = ProcTable.ps(Process.pid).rss * 0.004096
    end

    def vsize
      vsize = ProcTable.ps(Process.pid).vsize * 0.000001
    end
  end
end
