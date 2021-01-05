require 'rspec/expectations'

RSpec::Matchers.define(:resemble) do |expected|
  match do |actual|
    expect(normalize(actual)).to eq normalize(expected)
  end

  def normalize(text)
    text.gsub(/\s/m, '')
  end

  failure_message do |actual|
    <<~MESSAGE
      Expected

        `#{actual}`

      to resemble

        `#{expected}`
    MESSAGE
  end

  failure_message_when_negated do |actual|
    <<~MESSAGE
      Expected

        `#{actual}`

      to NOT resemble

        `#{expected}`
    MESSAGE
  end
end
