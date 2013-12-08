require 'logfile_interval'

module MemoryTracker
  module Stores
    class GcstatLogfileParser < LogfileInterval::LineParser::Base
      # Line format:
      # timestamp,action,count,heap_final_num,heap_free_num,heap_increment,heap_length,heap_live_num,heap_used,rss,total_allocated_object,total_freed_object,vsize


      set_regex /^(\d+),(\w+#\w+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),([\d\.]+),(\d+),(\d+),([\d\.]+)$/

      add_column :name => :timestamp,              :pos => 1,  :aggregator => :timestamp
      add_column :name => :action,                 :pos => 2,  :aggregator => :count, :group_by => :action
      add_column :name => :count,                  :pos => 3,  :aggregator => :average,   :conversion => :integer
#       add_column :name => :heap_final_num,         :pos => 4,  :aggregator => :average,   :conversion => :integer
#       add_column :name => :heap_free_num,          :pos => 5,  :aggregator => :average,   :conversion => :integer
#       add_column :name => :heap_increment,         :pos => 6,  :aggregator => :average,   :conversion => :integer
#       add_column :name => :heap_length,            :pos => 7,  :aggregator => :average,   :conversion => :integer
#       add_column :name => :heap_live_num,          :pos => 8,  :aggregator => :average,   :conversion => :integer
      add_column :name => :heap_used,              :pos => 9,  :aggregator => :average,   :conversion => :integer
      add_column :name => :rss,                    :pos => 10,  :aggregator => :delta,   :conversion => :float, :group_by => :action
      add_column :name => :total_allocated_object, :pos => 11,  :aggregator => :average,   :conversion => :integer
#       add_column :name => :total_freed_object,     :pos => 12, :aggregator => :average,   :conversion => :integer
      add_column :name => :vsize,                  :pos => 13, :aggregator => :delta,   :conversion => :float, :group_by => :action

      def time
        Time.at(self.timestamp.to_i)
      end
    end
  end
end
