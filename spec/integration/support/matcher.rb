require 'rspec/expectations'

RSpec::Matchers.define(:resemble) do |expected|
  match do |actual|
    normalize(actual).should eq normalize(expected)
  end

  def normalize(text)
    text.gsub(/\s/m, '')
  end

  failure_message_for_should do |actual|
    <<-MESSAGE.strip_heredoc
      Expected

        `#{actual}`

      to resemble

        `#{expected}`
    MESSAGE
  end

  failure_message_for_should_not do |actual|
    <<-MESSAGE.strip_heredoc
      Expected

        `#{actual}`

      to NOT resemble

        `#{expected}`
    MESSAGE
  end
end
