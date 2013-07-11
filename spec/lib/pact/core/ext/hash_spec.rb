require 'spec_helper'

describe 'Hash extension' do

  describe 'diffing' do

    context 'where an expected value is a non-empty string' do

      subject { {:a => 'a', :b => 'b'} }

      context 'and the actual value is an empty string' do

        let(:actual) { {:a => 'a', :b => ''} }

        it 'includes this in the diff' do
          expect(subject.diff_with_actual(actual)).to eql({:b => {:expected => 'b', :actual => ''}})
        end

      end

    end

  end

end