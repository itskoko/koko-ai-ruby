require 'spec_helper'

module Koko
  class Tracker
    describe Response do
      describe '#status' do
        it { expect(subject).to respond_to(:status) }
      end

      describe '#body' do
        it { expect(subject).to respond_to(:body) }
      end

      describe '#initialize' do
        let(:status) { 404 }
        let(:body)   { 'Oh No' }

        subject { described_class.new(status, body) }

        it 'sets the instance variable status' do
          expect(subject.instance_variable_get(:@status)).to eq(status)
        end

        it 'sets the instance variable body' do
          expect(subject.instance_variable_get(:@body)).to eq(body)
        end
      end
    end
  end
end
