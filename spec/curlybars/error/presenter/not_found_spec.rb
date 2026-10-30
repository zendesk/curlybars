# frozen_string_literal: true

describe Curlybars::Error::Presenter::NotFound do
  describe "#message" do
    it "mentions the path and the presenter class it looked for" do
      error = described_class.new("user/profile")

      expect(error.message).
        to eq("error compiling `user/profile`: could not find User::ProfilePresenter")
    end
  end
end
