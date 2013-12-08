require 'spec_helper'

GCSTAT_LOGFILE_DATA = <<LINES
1386125780,posts#index,49,0,63777,571,1431,349791,860,88.055808,1686477,1336686,269.484032
1386125782,posts#show,50,0,108615,517,1431,325083,914,90.218496,1770275,1445192,271.48287999999997
1386125784,posts#show,51,0,108361,513,1431,272900,918,90.759168,1826445,1553545,272.15871999999996
1386125785,posts#index,52,0,103229,513,1431,287439,918,90.759168,1917742,1630303,272.15871999999996
1386125787,posts#index,52,0,103386,513,1431,372228,918,91.29983999999999,2002688,1630460,272.78950399999997
1386125789,posts#index,54,0,101731,495,1431,289801,936,92.577792,2109945,1820144,273.77664
1386125792,posts#show,54,0,101731,495,1431,375282,936,92.577792,2195426,1820144,273.77664
1386125794,posts#show,55,0,123765,441,1431,324209,990,94.949376,2267943,1943734,276.271104
LINES

module MemoryTracker
  module Stores
    describe GcstatLogfileParser do
      before :each do
        @lines = GCSTAT_LOGFILE_DATA.split("\n")
        @parser = GcstatLogfileParser

        expectation = LogfileInterval::Logfile.any_instance.should_receive(:each_line)
        @lines.reverse.each { |line| expectation.and_yield(line) }
      end

      it 'iterates over each line' do
        logfile_iterator = LogfileInterval::Logfile.new('foo', @parser)
        result_lines = []
        logfile_iterator.each_line do |line|
          result_lines << line
        end

        result_lines.count.should == 8
        result_lines.first.should == @lines.last
        result_lines.last.should  == @lines.first
      end

      it 'iterates over each parsed line' do
        logfile_iterator = LogfileInterval::Logfile.new('foo', @parser)
        records = []
        logfile_iterator.each_parsed_line do |record|
          records << record
        end

        records.count.should == 8
        records.first.count.should == @lines.last.split(',')[2].to_i
        records.last.count.should  == @lines.first.split(',')[2].to_i
      end
    end
  end
end
