describe Curlybars::DeprecatedBranchesRemover do
  it "handles `{}` branches" do
    branches = {}

    Curlybars::DeprecatedBranchesRemover.perform!(branches)

    expect(branches).to eq({})
  end

  it "handles a hash containing { leaf: :deprecated }" do
    branches = { leaf: :deprecated }

    Curlybars::DeprecatedBranchesRemover.perform!(branches)

    expect(branches).to eq({})
  end

  it "handles `{ presenter: { leaf: :deprecated } }` branches" do
    branches = { presenter: { leaf: :deprecated } }

    Curlybars::DeprecatedBranchesRemover.perform!(branches)

    expect(branches).to eq(presenter: {})
  end

  it "handles a hash containing `{ collection: [{ leaf: :deprecated }] }` branches" do
    branches =  { collection: [{ leaf: :deprecated }] }

    Curlybars::DeprecatedBranchesRemover.perform!(branches)

    expect(branches).to eq(collection: [{}])
  end

  it "tolerates `nil` branches" do
    Curlybars::DeprecatedBranchesRemover.perform!(nil)
  end
end
