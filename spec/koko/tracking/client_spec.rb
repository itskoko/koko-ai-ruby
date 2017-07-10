require 'spec_helper'

module Koko
  class Tracker
    describe Client do
      let(:auth)        { 'secret' }
      let(:client)      { Client.new :auth => auth }
      let(:queue)       { client.instance_variable_get :@queue }
      let(:body)        { JSON.generate({}) }
      let(:status_code) { 200 }

      before { stub_request(:post, /.*/).to_return(body: body, status: status_code) }
      before { Timecop.freeze }

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

        context 'with a 400' do
          let(:status_code) { 400 }

          it 'raises an ArgumentError' do
            expect { client.track_content(Factory.content) }.to raise_error(ArgumentError)
          end
        end

        context 'with a 500' do
          let(:status_code) { 500 }

          it 'raises an RuntimeError' do
            expect { client.track_content(Factory.content) }.to raise_error(RuntimeError)
          end
        end

        it 'uses the current time if no timestamp is given' do
          client.track_content(Factory.content.merge("created_at" => nil))

          expected_body = JSON.generate(Factory.content.merge("created_at" => Time.now.iso8601))
          expect(WebMock).to have_requested(:post, "https://#{Defaults::Request.host}/track/content").with(body: expected_body)
        end

        it 'makes the correct request converting created_at time to iso8601 string' do
          client.track_content Factory.content

          expected_body = JSON.generate(Factory.content.merge("created_at" => Factory.content["created_at"].iso8601))
          expect(WebMock).to have_requested(:post, "https://#{Defaults::Request.host}/track/content").with(body: expected_body)
        end

        it 'returns the parsed body' do
          response_body = client.track_content(Factory.content)

          expect(response_body).to eq(JSON.load(body))
        end
      end

      describe '#track_flag' do
        context 'with a 400' do
          let(:status_code) { 400 }

          it 'raises an ArgumentError' do
            expect { client.track_flag(Factory.flag) }.to raise_error(ArgumentError)
          end
        end

        context 'with a 500' do
          let(:status_code) { 500 }

          it 'raises an RuntimeError' do
            expect { client.track_flag(Factory.flag) }.to raise_error(RuntimeError)
          end
        end

        it 'makes the correct request converting created_at time to float' do
          client.track_flag Factory.flag

          expected_body = JSON.generate(Factory.flag.merge("created_at" => Factory.flag["created_at"].iso8601))
          expect(WebMock).to have_requested(:post, "https://#{Defaults::Request.host}/track/flag").with(body: expected_body)
        end
      end

      describe '#track_moderation' do
        context 'with a 400' do
          let(:status_code) { 400 }

          it 'raises an ArgumentError' do
            expect { client.track_moderation(Factory.moderation) }.to raise_error(ArgumentError)
          end
        end

        context 'with a 500' do
          let(:status_code) { 500 }

          it 'raises an RuntimeError' do
            expect { client.track_moderation(Factory.moderation) }.to raise_error(RuntimeError)
          end
        end

        it 'makes the correct request converting created_at time to float' do
          client.track_moderation Factory.moderation

          expected_body = JSON.generate(Factory.moderation.merge("created_at" => Factory.moderation["created_at"].iso8601))
          expect(WebMock).to have_requested(:post, "https://#{Defaults::Request.host}/track/moderation").with(body: expected_body)
        end
      end
    end
  end
end
