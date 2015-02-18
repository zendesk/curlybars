require 'rspec/expectations'

RSpec::Matchers.define(:produce) do |expected|
  match do |actual|
    normalize(actual.map(&:type)).should eq normalize(expected)
  end

  def normalize(tokens)
    if tokens.last == :EOS
      tokens[0...-1]
    else
      tokens
    end
  end

  failure_message_for_should do |actual|
    <<-MESSAGE.strip_heredoc
      Expected

        #{normalize(actual.map(&:type))}

      to be

        #{normalize(expected)}
    MESSAGE
  end

  failure_message_for_should_not do |actual|
    <<-MESSAGE.strip_heredoc
      Expected

        #{normalize(actual)}

      to NOT be

        #{normalize(expected)}
    MESSAGE
  end
end
