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

    def self.track_block(*args)
      self.instance.track_block(*args)
    end

    def track_block(name, &block)
      raise ArgumentError unless block_given?
      before = GC.stat
      ret = yield
      after = GC.stat
      gcstat_logger.debug "gcstat diff for #{name}: #{GcStat.gcdiff(before, after)}"
      ret
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
