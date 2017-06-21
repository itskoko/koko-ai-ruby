require 'spec_helper'

module Koko
  class Tracker
    describe Tracker do
      let(:tracker) { Koko::Tracker.new :auth => 'secret', :stub => true }

      describe '#track' do
        it 'errors with incorrect attributes' do
          expect { tracker.track_content(:id => 'some_id') }.to raise_error(ArgumentError)
        end

        it 'does not error with the required options' do
          expect do
            tracker.track_content Factory.content
            sleep(1)
          end.to_not raise_error
        end
      end

      describe '#flush' do
        it 'flushes without error' do
          expect do
            tracker.track_content Factory.content
            tracker.flush
          end.to_not raise_error
        end
      end
    end
  end
end
