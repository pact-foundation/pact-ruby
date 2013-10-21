require 'spec_helper'

module Pact

  describe JsonWarning do

    class TestContract
      include JsonWarning
    end

    let(:logger) { double }

    before do
      Logger.stub(new: logger)
      @contract = TestContract.new
    end

    context 'when as_json has been clobbered' do
      before { @contract.stub(as_json_clobbered?: true) }

      it 'logs a single warning' do
        logger.should_receive(:warn).once
        @contract.check_for_active_support_json
        @contract.check_for_active_support_json
      end
    end

    context 'when as_json has NOT been clobbered' do
      before { @contract.stub(as_json_clobbered?: false) }

      it 'does not log a warning' do
        logger.should_not_receive(:warn)
        @contract.check_for_active_support_json
      end
    end

  end

end