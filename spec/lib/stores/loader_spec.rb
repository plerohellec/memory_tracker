require 'spec_helper'

module MemoryTracker
  module Stores
    describe Loader do
      context :register_store do
        it 'should record stores by name' do
          store_class = double('my_store_class')
          Loader.register_store :my_store, store_class
          Loader.store_classes.should include(:my_store)
        end
      end

      context :enable_store do
        it 'should send add_store to memory_tracker' do
          store_class = double('my_store_class')
          store       = double('my_store')
          allow(store_class).to receive(:new) { store }
          memory_tracker = double('memory_tracker')
          memory_tracker.should_receive(:add_store).with(store)

          Loader.register_store :my_store, store_class
          Loader.enable_store(memory_tracker, :name => :my_store)
        end
      end
    end
  end
end