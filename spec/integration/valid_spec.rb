describe "Curlybars.valid?" do
  it "returns true when the template has no validation errors" do
    expect(Curlybars.valid?({}, "Hello")).to be(true)
  end

  it "returns false when the template has validation errors" do
    expect(Curlybars.valid?({}, "{{subtitle}}")).to be(false)
  end
end
