module MemoryTracker
  module Stores
    class GcstatLogfileStore < Base
      register_store :gcstat_logfile

      def initialize(opts)
        logger_class = opts.fetch(:logger_class, 'Logger')
        filename     = opts.fetch(:filename, "#{Rails.root}/log/memtracker_gcstat.log")

        @logger = logger_class.constantize.new(filename)
        @num_lines = 0
      end

      def push(request)
        @request = request

        write_header if @num_lines % 1000 == 0
        write_request_log
        @num_lines += 1
      end

      def stats
      end

      private

      def write_header
        @logger.info "##{@request.end_gcstat.ordered_keys.join(',')}"
      end

      def write_request_log
        @logger.info logline
      end

      def logline
        @request.end_gcstat.ordered_values.join ','
      end
    end
  end
end
