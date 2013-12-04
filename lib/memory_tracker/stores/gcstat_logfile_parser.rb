require 'logfile_interval'

module MemoryTracker
  module Stores
    class GcstatLogfileParser < LogfileInterval::LineParser::Base
      # Line format:
      # timestamp,count,heap_final_num,heap_free_num,heap_increment,heap_length,heap_live_num,heap_used,rss,total_allocated_object,total_freed_object,vsize


      set_regex /^(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),([\d\.]+),(\d+),(\d+),([\d\.]+)$/

      add_column :name => :timestamp,              :pos => 1,  :agg_function => :timestamp
      add_column :name => :count,                  :pos => 2,  :agg_function => :average,   :conversion => :integer
#       add_column :name => :heap_final_num,         :pos => 3,  :agg_function => :average,   :conversion => :integer
#       add_column :name => :heap_free_num,          :pos => 4,  :agg_function => :average,   :conversion => :integer
#       add_column :name => :heap_increment,         :pos => 5,  :agg_function => :average,   :conversion => :integer
#       add_column :name => :heap_length,            :pos => 6,  :agg_function => :average,   :conversion => :integer
#       add_column :name => :heap_live_num,          :pos => 7,  :agg_function => :average,   :conversion => :integer
      add_column :name => :heap_used,              :pos => 8,  :agg_function => :average,   :conversion => :integer
      add_column :name => :rss,                    :pos => 9,  :agg_function => :average,   :conversion => :float
      add_column :name => :total_allocated_object, :pos => 10,  :agg_function => :average,   :conversion => :integer
#       add_column :name => :total_freed_object,     :pos => 11, :agg_function => :average,   :conversion => :integer
      add_column :name => :vsize,                  :pos => 12, :agg_function => :average,   :conversion => :float

      def time
        Time.at(self.timestamp.to_i)
      end
    end
  end
end
