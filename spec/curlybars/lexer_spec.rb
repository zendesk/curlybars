describe Curlybars::Lexer, ".lex" do
  it "returns the tokens in the source" do
    lex("foo {{bar}} baz").should == [
      :TEXT,
      :START, :PATH, :END,
      :TEXT, :EOS
    ]
  end

  it "scans components with identifiers" do
    lex("{{foo.bar}}").should == [:START, :PATH, :END, :EOS]
  end

  it "scans components as partial" do
    lex("{{> foo}}").should == [:START, :GT, :PATH, :END, :EOS]
  end

  it "scans comments in the source" do
    lex("foo {{!bar}} baz").should == [:TEXT, :TEXT, :EOS]
  end

  it "allows newlines in comments" do
    lex("{{!\nfoo\n}}").should == [:EOS]
  end

  it "scans to the end of the source" do
    lex("foo\n").should == [:TEXT, :EOS]
  end

  it "scans context block tags with the with syntax" do
    lex('{{#with bar}} hello {{/with}}').should == [
      :START, :HASH, :WITH, :PATH, :END,
      :TEXT,
      :START, :SLASH, :WITH, :END, :EOS
    ]
  end

  it "scans conditional block tags with the if syntax" do
    lex('foo {{#if bar?}} hello {{/if}}').should == [
      :TEXT, :START, :HASH, :IF, :PATH, :END,
      :TEXT, :START, :SLASH, :IF, :END, :EOS
    ]
  end

  it "scans conditional block tags with the else token" do
    lex('foo {{#if bar?}} hello {{else}} bye {{/if}}').should == [
      :TEXT, :START, :HASH, :IF, :PATH, :END,
      :TEXT, :START, :ELSE, :END,
      :TEXT, :START, :SLASH, :IF, :END, :EOS
    ]
  end

  it "scans inverse block tags using the unless syntax" do
    lex('foo {{#unless bar?}} hello {{/unless}}').should == [
      :TEXT, :START, :HASH, :UNLESS, :PATH, :END,
      :TEXT, :START, :SLASH, :UNLESS, :END, :EOS
    ]
  end

  it "scans inverse conditional block tags with the else token" do
    lex('foo {{#unless bar?}} hello {{else}} bye {{/unless}}').should == [
      :TEXT, :START, :HASH, :UNLESS, :PATH, :END,
      :TEXT, :START, :ELSE, :END,
      :TEXT, :START, :SLASH, :UNLESS, :END, :EOS
    ]
  end

  it "scans collection block tags with the each syntax" do
    lex('foo {{#each bar}} hello {{/each}}').should == [
      :TEXT, :START, :HASH, :EACH, :PATH, :END,
      :TEXT, :START, :SLASH, :EACH, :END, :EOS
    ]
  end

  it "treats quotes as text" do
    lex('"').should == [:TEXT, :EOS]
  end

  it "treats Ruby interpolation as text" do
    lex('#{foo}').should == [:TEXT, :EOS]
  end
end
