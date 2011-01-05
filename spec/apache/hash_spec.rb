require 'spec_helper'
require 'lib/apache/hash'

describe Hash do
  describe '#to_sym_keys' do
    subject { test_hash.to_sym_keys }

    context 'no nested hashes' do
      let(:test_hash) { {
        'hello' => 'goodbye',
        :other => 'this'
      } }

      it { should == {
        :hello => 'goodbye',
        :other => 'this'
      } }
    end

    context 'nested hash' do
      let(:test_hash) { {
        'hello' => 'goodbye',
        :other => {
          'this' => 'that'
        }
      } }

      it { should == {
        :hello => 'goodbye',
        :other => {
          :this => 'that'
        }
      } }
    end
  end
end
