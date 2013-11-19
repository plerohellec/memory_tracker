require 'spec_helper'

def sample_stats(factor=1)
  base = {
      :rss                      => 1,
      :vsize                    => 2,
      :count                    => 4,
      :heap_used                => 86,
      :heap_length              => 138,
      :heap_increment            =>52,
      :heap_live_num             =>34768,
      :heap_free_num             =>22099,
      :heap_final_num            =>0,
      :total_allocated_object    =>68540,
      :total_freed_object        =>33772
    }
  sample = {}
  base.each { |k,v| sample[k] = v * factor }
  sample
end

def stub_gcstat_delta(controller, action, factor=1)
  allow(@env).to receive(:controller) { controller }
  allow(@env).to receive(:action)     { action }
  MemoryTracker::GcStatDelta.any_instance.stub(:stats) { sample_stats(factor) }
end

module MemoryTracker
  module Stores
    module InMemoryStore
      describe Manager do
        def start_time
          Time.new(2013,01,01,0,0,0)
        end

        before :each do
          @env = double('env')
        end

        it 'should respond to name' do
          manager = Manager.new(:window_length => 60)
          manager.should respond_to(:name)
        end

        it 'should return stats from older window' do
          Time.stub(:now).and_return(start_time)
          manager = Manager.new(:window_length => 60)
          request = Request.new(@env)
          stub_gcstat_delta('Boat', 'sail')
          manager.push(request.close)
          Time.stub(:now).and_return(start_time + 10)
          request = Request.new(@env)
          stub_gcstat_delta('Car', 'drive', 2)
          manager.push(request.close)
          Time.stub(:now).and_return(start_time + 40)
          request = Request.new(@env)
          stub_gcstat_delta('Boat', 'sail', 3)
          manager.push(request.close)

          stats = manager.stats
          stats.fetch('Boat', 'sail', :rss).should == 4
          stats.fetch('Car', 'drive', :rss).should  == 2
        end

        it 'should rotate windows' do
          Time.stub(:now).and_return(start_time)
          manager = Manager.new(:window_length => 60)
          request = Request.new(@env)
          stub_gcstat_delta('Boat', 'sail')
          manager.push(request.close)
          Time.stub(:now).and_return(start_time + 10)
          request = Request.new(@env)
          stub_gcstat_delta('Car', 'drive', 2)
          manager.push(request.close)
          Time.stub(:now).and_return(start_time + 40)
          request = Request.new(@env)
          stub_gcstat_delta('Boat', 'sail', 3)
          manager.push(request.close)
          Time.stub(:now).and_return(start_time + 70)

          stats = manager.stats
          stats.fetch('Boat', 'sail', :rss).should == 3
          stats.fetch('Car', 'drive', :rss).should be_nil
        end
      end

      describe StatInterval do

        before :each do
          @interval = InMemoryStore::StatInterval.new(Time.now, 5*60)
          @env = double('env')
        end

        it 'should accept requests' do
          env = double('env')
          request = Request.new(env)
          allow(env).to receive(:controller) { :Foo }
          allow(env).to receive(:action)     { :bar }
          request.close
          request.controller.should == :Foo
          request.action.should == :bar
          @interval.push(request)
        end

        it 'should accumulate one request' do
          req1 = Request.new(@env)
          req1.close
          stub_gcstat_delta('Boat', 'sail')
          @interval.push(req1)
          @interval.stats.should be_a(Stats)
          @interval.stats.fetch('Boat', 'sail', :rss).should == 1
        end

        it 'should accumulate several requests' do
          req1 = Request.new(@env)
          req1.close
          stub_gcstat_delta('Boat', 'sail')
          @interval.push(req1)
          req2 = Request.new(@env)
          req2.close
          stub_gcstat_delta('Boat', 'sail', 2)
          @interval.push(req2)
          req3 = Request.new(@env)
          req3.close
          stub_gcstat_delta('Boat', 'moor', 5)
          @interval.push(req3)
          req4 = Request.new(@env)
          req4.close
          stub_gcstat_delta('Car', 'drive', 1)
          @interval.push(req4)

          stats = @interval.stats
          stats.count('Boat', 'sail').should == 2
          stats.fetch('Boat', 'sail', :rss).should   == 3
          stats.fetch('Boat', 'sail', :count).should == 12
          stats.count('Boat', 'moor').should == 1
          stats.fetch('Boat', 'moor', :rss).should   == 5
          stats.fetch('Boat', 'moor', :count).should == 20
          stats.count('Car', 'drive').should == 1
          stats.fetch('Car', 'drive', :rss).should   == 1
          stats.fetch('Car', 'drive', :count).should == 4
        end

        it 'should be enumerable' do
          req1 = Request.new(@env)
          req1.close
          stub_gcstat_delta('Boat', 'sail')
          @interval.push(req1)
          req2 = Request.new(@env)
          req2.close
          stub_gcstat_delta('Boat', 'moor')
          @interval.push(req2)

          @interval.size.should == 2
          @interval.to_a.should include(['Boat', 'sail', { :num => 1, :gcstat => sample_stats} ])
          @interval.to_a.should include(['Boat', 'moor', { :num => 1, :gcstat => sample_stats} ])
        end
      end
    end
  end
end