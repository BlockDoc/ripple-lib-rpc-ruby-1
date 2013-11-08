require File.expand_path('../../../spec_helper', __FILE__)

describe Ripple::Client do
  context ".account_lines" do
    it "should return the account lines" do
      Ripple.configure do |config|
        config.client_account = "rHb9CJAWyB4rj91VRWn96DkukG4bwdtyTh"
      end
      VCR.use_cassette('account_lines') do
        Ripple.account_lines
      end
    end
  end
end