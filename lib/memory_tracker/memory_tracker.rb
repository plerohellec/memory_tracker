module MemoryTracker
  class MemoryTracker
    include Singleton
    include Enumerable

    attr_accessor :config

    def stores
      @stores ||= {}
    end

    def add_store(store)
      stores[store.name] = store
    end
    
    def start_request(env)
      @request = Request.new(env)
    end

    def end_request
      return unless @request
      @request.close
      stores.each { |name, store| store.push(@request) }

      @request = nil
    end

    def stats(store_name)
      stores[store_name].stats
    end

    private
    
    def each_store
      stores.each
    end
    
    def each
      each_store
    end
  end
end
