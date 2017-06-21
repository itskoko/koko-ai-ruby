require 'spec_helper'

module Koko
  class Tracker
    describe Client do
      let(:auth)   { 'secret' }
      let(:client) { Client.new :auth => auth }
      let(:queue)  { client.instance_variable_get :@queue }
      let(:body) { JSON.generate({}) }

      before { stub_request(:post, /.*/).and_return(body: body) }

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
        let(:body) { JSON.generate(Factory.behavorial_classification) }

        it 'errors with invalid arguments' do
          expect { client.track_content(:user_id => 'user') }.to raise_error(ArgumentError)
        end

        it 'uses the current time if no timestamp is given' do
          client.track_content(Factory.content.merge("created_at" => nil))

          msg = queue.pop

          expect(msg[:body][:created_at]).to_not be_nil
        end

        it 'does not error with the required options' do
          expect do
            client.track_content Factory.content
            queue.pop
          end.to_not raise_error
        end

        it 'does not error when given string keys' do
          expect do
            client.track_content Utils.stringify_keys(Factory.content)
            queue.pop
          end.to_not raise_error
        end

        it 'makes the correct request converting created_at time to float' do
          client.track_content Factory.content
          client.flush

          expected_body = JSON.generate(Factory.content.merge("created_at" => Factory.content["created_at"].to_f))
          expect(WebMock).to have_requested(:post, "https://#{Defaults::Request.host}/track/content").with(body: expected_body)
        end

        it 'returns the parsed body if a block is passed' do
          response_body = nil
          client.track_content(Factory.content) do |response|
            response_body = response
          end
          expect(response_body).to eq(JSON.load(body))
        end
      end

      describe '#track_flag' do
        it 'errors with invalid arguments' do
          expect { client.track_flag(:user_id => 'user') }.to raise_error(ArgumentError)
        end

        it 'makes the correct request converting created_at time to float' do
          client.track_flag Factory.flag
          client.flush

          expected_body = JSON.generate(Factory.flag.merge("created_at" => Factory.flag["created_at"].to_f))
          expect(WebMock).to have_requested(:post, "https://#{Defaults::Request.host}/track/flag").with(body: expected_body)
        end
      end

      describe '#track_moderation' do
        it 'errors with invalid arguments' do
          expect { client.track_moderation(:user_id => 'user') }.to raise_error(ArgumentError)
        end

        it 'makes the correct request converting created_at time to float' do
          client.track_moderation Factory.moderation
          client.flush

          expected_body = JSON.generate(Factory.moderation.merge("created_at" => Factory.moderation["created_at"].to_f))
          expect(WebMock).to have_requested(:post, "https://#{Defaults::Request.host}/track/moderation").with(body: expected_body)
        end
      end

      describe '#flush' do
        it 'waits for the queue to finish on a flush' do
          client.track_content Factory.content
          client.track_content Factory.content

          expect(client.queued_messages).to eq(2)

          client.flush

          expect(client.queued_messages).to eq(0)
        end

        it 'completes when the process forks' do
          client.track_content Factory.content

          Process.fork do
            client.track_content Factory.content
            client.flush
            expect(client.queued_messages).to eq(0)
          end

          Process.wait
        end unless defined? JRUBY_VERSION
      end
    end
  end
end
