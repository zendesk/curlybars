describe Curlybars::Processor::Tilde do
  let(:tilde_start_token) { double(:tilde_start, type: :TILDE_START, value: nil, position: nil) }
  let(:tilde_end_token) { double(:tilde_end, type: :TILDE_END, value: nil, position: nil) }
  let(:start_token) { double(:start, type: :START, value: nil, position: nil) }
  let(:end_token) { double(:end, type: :END, value: nil, position: nil) }

  describe ":TILDE_START" do
    it "trims the previous text token" do
      tokens = [
        text_token("text \t\r\n"),
        tilde_start_token
      ]
      Curlybars::Processor::Tilde.process!(tokens)

      expect(tokens.first.value).to eq 'text'
    end

    it "doesn't trim the previous text token when not right before" do
      tokens = [
        text_token("text \t\r\n"),
        start_token,
        end_token,
        tilde_start_token
      ]
      Curlybars::Processor::Tilde.process!(tokens)

      expect(tokens.first.value).to eq "text \t\r\n"
    end
  end

  describe ":TILDE_END" do
    it "trims the following text token" do
      tokens = [
        tilde_end_token,
        text_token("\t\r\n text")
      ]
      Curlybars::Processor::Tilde.process!(tokens)

      expect(tokens.last.value).to eq 'text'
    end

    it "doesn't trim the following text token when not right after" do
      tokens = [
        tilde_end_token,
        start_token,
        end_token,
        text_token("\t\r\n text")
      ]
      Curlybars::Processor::Tilde.process!(tokens)

      expect(tokens.last.value).to eq "\t\r\n text"
    end
  end

  private

  def text_token(value)
    double(:text, type: :TEXT, value: value, position: nil)
  end
end
