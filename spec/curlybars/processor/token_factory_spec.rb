# frozen_string_literal: true

describe Curlybars::Processor::TokenFactory do
  let(:token_factory) do
    Class.new { extend Curlybars::Processor::TokenFactory }
  end

  it "builds a token" do
    expect(token_factory.create_token(:PATH, "a", nil)).to be_a(Curlybars::Token)
  end
end
