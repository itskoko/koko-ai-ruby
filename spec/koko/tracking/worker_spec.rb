require 'spec_helper'

module Koko
  class Tracker
    describe Worker do
      describe "#init" do
        it 'accepts string keys' do
          queue = Queue.new
          error_proc = Proc.new {}
          worker = Koko::Tracker::Worker.new(queue, 'secret', 'on_error' => error_proc)
          expect(worker.instance_variable_get(:@on_error)).to eq(error_proc)
        end
      end

      describe '#run' do
        before :all do
          Defaults::Request.backoff = 0.1
        end

        after :all do
          Defaults::Request.backoff = 30.0
        end

        it 'does not error if the endpoint is unreachable' do
          expect do
            stub_request(:any, /#{Defaults::Request.host}/).and_raise(Exception)

            queue = Queue.new
            queue << {}
            worker = Koko::Tracker::Worker.new(queue, 'secret')
            worker.run

            expect(queue).to be_empty
          end.to_not raise_error
        end

        it 'executes the error handler, before the request phase ends, if the request is invalid' do
          Koko::Tracker::Request.any_instance.stub(:post).and_return(Koko::Tracker::Response.new(400, "Some error"))

          status = error = nil
          on_error = Proc.new do |yielded_status, yielded_error|
            sleep 0.2 # Make this take longer than thread spin-up (below)
            status, error = yielded_status, yielded_error
          end

          queue = Queue.new
          queue << {}
          worker = Koko::Tracker::Worker.new queue, 'secret', :on_error => on_error

          # This is to ensure that Client#flush doesn’t finish before calling the error handler.
          Thread.new { worker.run }
          sleep 0.1 # First give thread time to spin-up.
          sleep 0.01 while worker.is_requesting?

          Koko::Tracker::Request::any_instance.unstub(:post)

          expect(queue).to  be_empty
          expect(status).to eq(400)
          expect(error).to  eq('Some error')
        end

        it 'does not call on_error if the request is good' do
          Koko::Tracker::Request.any_instance.stub(:post).and_return(Koko::Tracker::Response.new(200, {}))

          on_error = Proc.new do |status, error|
            puts "#{status}, #{error}"
          end

          expect(on_error).to_not receive(:call)

          queue = Queue.new
          queue << Factory.content
          worker = Koko::Tracker::Worker.new queue, 'testsecret', :on_error => on_error
          worker.run

          expect(queue).to be_empty
        end
      end

      describe '#is_requesting?' do
        it 'does not return true if there isn\'t a current batch' do
          queue = Queue.new
          worker = Koko::Tracker::Worker.new(queue, 'testsecret')

          expect(worker.is_requesting?).to eq(false)
        end

        # Race Condition
        # When we call worker.ran it creates new Request object and
        # do post request. So we expect to check a batch is running.
        # In eventually function we check for 5 seconds that
        # all batches finished its process.

        it 'returns true if there is a current batch' do
          queue = Queue.new
          queue << Factory.content
          worker = Koko::Tracker::Worker.new(queue, 'testsecret')

          Thread.new do
            worker.run
            expect(worker.is_requesting?).to eq(true)
          end

          eventually { expect(worker.is_requesting?).to eq(false) }

        end
      end
    end
  end
end
