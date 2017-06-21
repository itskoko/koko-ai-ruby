require 'spec_helper'

module Koko
  class Tracker
    describe Client do
      let(:client) { Client.new :auth => 'someauth' }
      let(:queue) { client.instance_variable_get :@queue }

      describe '#initialize' do
        it 'errors if no auth is supplied' do
          expect { Client.new }.to raise_error(ArgumentError)
        end

        it 'does not error if a auth is supplied' do
          expect do
            Client.new :auth => auth
          end.to_not raise_error
        end

        it 'does not error if a auth is supplied as a string' do
          expect do
            Client.new 'auth' => auth
          end.to_not raise_error
        end
      end

      describe '#track_content' do
        it 'errors without an event' do
          expect { client.track(:user_id => 'user') }.to raise_error(ArgumentError)
        end

        it 'errors without a user_id' do
          expect { client.track(:event => 'Event') }.to raise_error(ArgumentError)
        end

        it 'errors if properties is not a hash' do
          expect {
            client.track({
              :user_id => 'user',
              :event => 'Event',
              :properties => [1,2,3]
            })
          }.to raise_error(ArgumentError)
        end

        it 'uses the timestamp given' do
          time = Time.parse("1990-07-16 13:30:00.123 UTC")

          client.track({
            :event => 'testing the timestamp',
            :user_id => 'joe',
            :timestamp => time
          })

          msg = queue.pop

          expect(Time.parse(msg[:timestamp])).to eq(time)
        end

        it 'does not error with the required options' do
          expect do
            client.track Queued::TRACK
            queue.pop
          end.to_not raise_error
        end

        it 'does not error when given string keys' do
          expect do
            client.track Utils.stringify_keys(Queued::TRACK)
            queue.pop
          end.to_not raise_error
        end

        it 'converts time and date traits into iso8601 format' do
          client.track({
            :user_id => 'user',
            :event => 'Event',
            :properties => {
              :time => Time.utc(2013),
              :time_with_zone =>  Time.zone.parse('2013-01-01'),
              :date_time => DateTime.new(2013,1,1),
              :date => Date.new(2013,1,1),
              :nottime => 'x'
            }
          })
          message = queue.pop

          expect(message[:properties][:time]).to eq('2013-01-01T00:00:00.000Z')
          expect(message[:properties][:time_with_zone]).to eq('2013-01-01T00:00:00.000Z')
          expect(message[:properties][:date_time]).to eq('2013-01-01T00:00:00.000Z')
          expect(message[:properties][:date]).to eq('2013-01-01')
          expect(message[:properties][:nottime]).to eq('x')
        end
      end


      describe '#flush' do
        it 'waits for the queue to finish on a flush' do
          client.track_content Factory::Content
          client.track_content Factory::Content

          expect(client.queued_messages).to eq(2)

          client.flush

          expect(client.queued_messages).to eq(0)
        end

        it 'completes when the process forks' do
          client.track_content Factory::Content

          Process.fork do
            client.track_content Factory::Content
            client.flush
            expect(client.queued_messages).to eq(0)
          end

          Process.wait
        end unless defined? JRUBY_VERSION
      end
    end
  end
end
