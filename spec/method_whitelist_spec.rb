describe Curlybars::MethodWhitelist do
  class BasePresenter
    extend Curlybars::MethodWhitelist
    allow_methods :cook
  end

  module Helpers
    extend Curlybars::MethodWhitelist
    allow_methods :form
  end

  class PostPresenter < BasePresenter
    include Helpers
    allow_methods :wave
  end

  class DoNothing
    extend Curlybars::MethodWhitelist
  end

  describe "#allowed_methods" do
    it "should return an empty array as default" do
      expect(DoNothing.new.allowed_methods).to eq([])
    end

    it "should return the allowed method" do
      expect(BasePresenter.new.allowed_methods).to eq([:cook])
    end

    it "should return methods from inheritance and composition" do
      expect(PostPresenter.new.allowed_methods).to eq([:cook, :form, :wave])
    end
  end
end
