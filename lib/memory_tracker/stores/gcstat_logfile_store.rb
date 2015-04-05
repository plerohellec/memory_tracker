module MemoryTracker
  module Stores
    class GcstatLogfileStore < Base
      register_store :gcstat_logfile

      COLUMNS = [ :count, :heap_final_num, :heap_free_num, :heap_length, :heap_live_num, :heap_used, :rss, :total_allocated_object, :total_freed_object, :vsize ]

      def initialize(opts)
        logger_class = opts.fetch(:logger_class, 'Logger')
        filename     = opts.fetch(:filename, "#{Rails.root}/log/memtracker_gcstat.log")

        @logger = logger_class.constantize.new(filename)
        if @logger.respond_to?(:formatter)
          @logger.formatter = proc do |severity, datetime, progname, msg|
            "#{msg}\n"
          end
        end

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
        @logger.info "##{COLUMNS.join(',')}"
      end

      def write_request_log
        @logger.info "#{Time.now.to_i},#{logline}"
      end

      def logline
        logline = "#{@request.controller}##{@request.action},"
        logline << @request.end_gcstat.ordered_values(COLUMNS).join(',')
      end
    end
  end
end
