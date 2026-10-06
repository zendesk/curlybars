describe Curlybars::SerializationGuard do
  def build(budget: 1_000, depth_limit: 3)
    described_class.new(budget: budget, depth_limit: depth_limit)
  end

  describe "#measure" do
    it "accumulates string bytesize and raises once over budget" do
      guard = build(budget: 5)
      guard.measure("ab")

      expect { guard.measure("cdef") }.
        to raise_error(an_instance_of(Curlybars::Error::Render).and(having_attributes(id: 'render.output_too_long')))
    end

    it "ignores non-string values" do
      guard = build(budget: 1)

      aggregate_failures do
        expect { guard.measure(1_000_000) }.not_to raise_error
        expect { guard.measure(a: 1) }.not_to raise_error
      end
    end
  end

  describe "#enter! / #leave!" do
    it "raises once depth exceeds the limit" do
      guard = build(depth_limit: 2)
      guard.enter!
      guard.enter!

      expect { guard.enter! }.
        to raise_error(an_instance_of(Curlybars::Error::Render).and(having_attributes(id: 'render.nesting_too_deep')))
    end

    it "recovers depth on leave!" do
      guard = build(depth_limit: 1)
      guard.enter!
      guard.leave!

      expect { guard.enter! }.not_to raise_error
    end
  end
end
