module MemoryTracker
  class Env
    attr_reader :path, :controller, :action

    def initialize(env)
      @path = env['PATH_INFO']

      begin
        routes_env = { :method => env['REQUEST_METHOD'] }
        request = Rails.application.routes.recognize_path(env['REQUEST_PATH'], routes_env)
        @controller = request[:controller]
        @action     = request[:action]
      rescue ActionController::RoutingError
        @controller = 'unknown'
        @action = 'unknown'
      end
    end
  end
end
