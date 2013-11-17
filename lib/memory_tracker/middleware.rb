module MemoryTracker
  # Middleware responsability is to initialize and close request objects
  # object at start and end of HTTP query.
  class Middleware
    def initialize(app)
      @app = app
    end

    def memory_tracker
      MemoryTracker.instance
    end

    def call(env)
      memory_tracker.start_request(Env.new(env))
      status, headers, body = @app.call(env)
    ensure
      memory_tracker.end_request
    end
  end  
end
