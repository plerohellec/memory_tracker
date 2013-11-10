module MemoryTracker
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
