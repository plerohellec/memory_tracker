module MemoryTracker
  module Stores
    class UrlLogfileStore < Base
      register_store :url_logfile

      def initialize(opts)
        logger_class = opts.fetch(:logger_class, 'Logger')
        filename     = opts.fetch(:filename, "#{Rails.root}/log/memtracker_urls.log")

        @logger = logger_class.constantize.new(filename)
      end

      def push(request)
        @request = request
        write_request_log
      end

      def stats
      end

      private

      def write_request_log
        @logger.info logline
      end

      def logline
        pid = Process.pid

        end_gcstats   = @request.end_gcstat.stats
        start_gcstats = @request.start_gcstat.stats
        delta_gcstats = @request.gcstat_delta.stats

        log_msg = "#{Time.now.localtime.strftime("%m-%d %H:%M:%S")} pid:#{'%05d' % pid}"
        log_msg << " rss=#{'%6.2f' % end_gcstats[:rss]}"
        log_msg << " vsize=#{'%6.2f' % end_gcstats[:vsize]}"

        if (end_gcstats[:rss] / start_gcstats[:rss] > 1.005) || delta_gcstats[:heap_used] > 0
          log_msg << " *** #{@request.gcstat_delta.custom.inspect}"
        end

        log_msg << " #{@request.path}"
      end
    end
  end
end
