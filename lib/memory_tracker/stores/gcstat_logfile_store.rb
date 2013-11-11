module MemoryTracker
  module Stores
    class GcstatLogfileStore
      def initialize(logger_class, logfile_path)
        @logger = logger_class.new(logfile_path)
        @num_lines = 0
      end

      def name
        :gcstat_logfile
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
