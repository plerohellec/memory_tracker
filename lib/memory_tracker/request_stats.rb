module MemoryTracker
  class RequestStats

    attr_reader :controller_name, :action_name
    attr_reader :operation_stats, :table_stats, :join_stats

    attr_accessor :status

    def initialize(env)
      begin
        routes_env = { :method => env['REQUEST_METHOD'] }
        request = Rails.application.routes.recognize_path(env['REQUEST_URI'], routes_env)

        @env = env
        @controller_name  = request[:controller]
        @action_name      = request[:action]

      rescue
        @controller_name  = nil
        @action_name      = nil
      end
    end

    def path
      @env['PATH_INFO']
    end

    def push(parser)
#       return unless parser.parse
#       parser.log
#
#       return if parser.invalid
#
#       case parser.class.to_s
#       when 'MemoryTracker::SqlParser'          then query_type = :sql
#       when 'MemoryTracker::RecordCacheParser'  then query_type = :rc
#       end
#
#       increment_item(@table_stats,     query_type, parser.table_name)
#       increment_item(@operation_stats, query_type, parser.operation)
#       parser.join_tables.each do |table|
#         increment_item(@join_stats, query_type, join_string(parser.table_name, table))
#       end
    end

    def close
    end

   private

    def increment_item(hash, type, key)
#       Rails.logger.debug "increment_item: hash=#{hash.inspect}"
#       Rails.logger.debug "increment_item: query_type=#{query_type} key=#{key}"
      if hash[type].has_key?(key)
        hash[type][key] += 1
      else
        hash[type][key] = 1
      end
    end

    def join_string(t1, t2)
      "#{t1}|#{t2}"
    end
  end
end
