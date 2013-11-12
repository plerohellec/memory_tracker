module MemoryTracker
  module Stores
    describe UrlLogfileStore do
      before :each do
        logger_class = double("logger_class")
        allow(logger_class).to receive(:new)
        @logstore = UrlLogfileStore.new logger_class, "foo/log"
      end

      it 'implements the store role' do
        @logstore.should respond_to(:name)
        @logstore.should respond_to(:push)
        @logstore.should respond_to(:stats)
      end
    end
  end
end
