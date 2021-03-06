require 'spec_helper'

module Koko
  class Tracker
    describe Request do
      before do
        # Try and keep debug statements out of tests
        allow(subject.logger).to receive(:error)
        allow(subject.logger).to receive(:debug)
      end

      describe '#initialize' do
        let!(:net_http) { Net::HTTP.new(anything, anything) }

        before do
          allow(Net::HTTP).to receive(:new) { net_http }
        end

        it 'sets an initalized Net::HTTP read_timeout' do
          expect(net_http).to receive(:use_ssl=)
          described_class.new
        end

        it 'sets an initalized Net::HTTP read_timeout' do
          expect(net_http).to receive(:read_timeout=)
          described_class.new
        end

        it 'sets an initalized Net::HTTP open_timeout' do
          expect(net_http).to receive(:open_timeout=)
          described_class.new
        end

        it 'sets the http client' do
          expect(subject.http).to_not be_nil
        end

        context 'no options are set' do
          it 'sets a default path' do
            expect(subject.instance_variable_get(:@path)).to eq(Defaults::Request.path)
          end

          it 'initializes a new Net::HTTP with default host and port' do
            expect(Net::HTTP).to receive(:new).with(Defaults::Request.host, Defaults::Request.port)
            described_class.new
          end
        end

        context 'options are given' do
          let(:path) { 'my/cool/path' }
          let(:host) { 'http://www.example.com' }
          let(:port) { 8080 }
          let(:options) do
            {
              path: path,
              host: host,
              port: port
            }
          end

          subject { described_class.new(options) }

          it 'sets passed in path' do
            expect(subject.instance_variable_get(:@path)).to eq(path)
          end

          it 'initializes a new Net::HTTP with passed in host and port' do
            expect(Net::HTTP).to receive(:new).with(host, port)
            described_class.new(options)
          end
        end
      end

      describe '#post' do
        let(:subject) { Request.new(backoff: 0) }

        let(:response_body) { {}.to_json }
        let(:auth) { 'abcdefg' }
        let(:body) { { some: 'value' } }

        it 'makes a request with the correct headers and body' do
          stub_request(:post, /#{subject.http.address}/).
            with(body: body, headers: { 'Content-Type' => 'application/json', 'authorization' => auth }).
            to_return(body: response_body)

          response = subject.post(auth, body)

          expect(response.body).to eq({})
        end

        context 'with a stub' do
          before do
            allow(described_class).to receive(:stub) { true }
          end

          it 'returns a 200 response' do
            expect(subject.post(auth, body).status).to eq(200)
          end

          it 'logs a debug statement' do
            expect(subject.logger).to receive(:debug).with(/stubbed request to/)
            subject.post(auth, body)
          end
        end

        context 'a real request' do
          let(:status_code) { 200 }

          before do
            stub_request(:post, /.*/).
            to_return(body: response_body, status: status_code)
          end

          context 'request is successful' do
            let(:status_code) { 201 }

            it 'returns a response code' do
              expect(subject.post(auth, body).status).to eq(status_code)
            end
          end

          context 'request results in 400 ' do
            let(:error)       { 'this is an error' }
            let(:status_code) { 400 }
            let(:response_body) { { error: error }.to_json }

            it 'returns the parsed error' do
              expect(subject.post(auth, body).body).to eq({ "error" => error })
            end
          end

          context 'request results in 500 ' do
            let(:status_code)   { 500 }
            let(:response_body) { "Something is wrong" }

            it 'returns the body raw' do
              expect(subject.post(auth, body).body).to eq("Something is wrong")
            end
          end
        end

        context 'request or parsing of response results in an exception' do
          let(:response_body) { 'Malformed JSON ---' }

          it 'has a connection error' do
            expect(subject.post(auth, body).body).to match(/Connection error/)
          end
        end
      end
    end
  end
end
