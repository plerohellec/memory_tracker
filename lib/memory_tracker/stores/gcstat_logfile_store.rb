module MemoryTracker
  module Stores
    class GcstatLogfileStore
      def initialize(logger_class, logfile_path)
        @logger = logger_class.new(logfile_path)
      end

      def name
        :gcstat_logfile
      end

      def push(request)
        @logger.info logline
      end

      def stats
      end

      private

      def logline
        @request.end_gcstat.values.join ','
      end
    end
  end
end
