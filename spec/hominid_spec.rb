require 'spec/spec_helper'

describe Hominid do
  before do
    api_key = ENV['MAIL_CHIMP_API_KEY']
    raise "You must set the MAIL_CHIMP_API_KEY environment variable to test" if api_key.empty?
    @hominid = Hominid.new(:api_key => api_key)
    @list_id = ENV['MAIL_CHIMP_TEST_LIST_ID']
    raise "You must set the MAIL_CHIMP_TEST_LIST_ID environment variable to test" if @list_id.empty?
  end
  
  describe "#subscribe" do
    context "when not supplying a double-opt-in argument" do
      it "should not blow up" do
        proc {
          @hominid.subscribe(@list_id, Faker::Internet.email)
        }.should_not raise_error
      end
    end
  end

  describe "#call" do
    it "should raise HominidError on failure" do
      proc {
        Hominid.new.send(:call, 'bogusApi')
      }.should raise_error(HominidError)
    end
  end
end