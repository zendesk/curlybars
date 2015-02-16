describe Curlybars::Lexer, ".lex" do
  it 'is an RLTK lexer' do
    subject.should be_a(RLTK::Lexer)
  end

  it "returns the tokens in the source" do
    map_lex_type("foo {{bar}} baz").should == [
      :TEXT,
      :START, :PATH, :END,
      :TEXT, :EOS
    ]
  end

  it "scans components with identifiers" do
    map_lex_type("{{foo.bar}}").should == [:START, :PATH, :END, :EOS]
  end

  it "scans comments in the source" do
    map_lex_type("foo {{!bar}} baz").should == [:TEXT, :TEXT, :EOS]
  end

  it "allows newlines in comments" do
    map_lex_type("{{!\nfoo\n}}").should == [:EOS]
  end

  it "scans to the end of the source" do
    map_lex_type("foo\n").should == [:TEXT, :EOS]
  end

  it "scans context block tags with the with syntax" do
    map_lex_type('{{#with bar}} hello {{/with}}').should == [
      :START, :HASH, :WITH, :PATH, :END,
      :TEXT,
      :START, :SLASH, :WITH, :END, :EOS
    ]
  end

  it "scans conditional block tags with the if syntax" do
    map_lex_type('foo {{#if bar?}} hello {{/if}}').should == [
      :TEXT, :START, :HASH, :IF, :PATH, :END,
      :TEXT, :START, :SLASH, :IF, :END, :EOS
    ]
  end

  it "scans conditional block tags with the else token" do
    map_lex_type('foo {{#if bar?}} hello {{else}} bye {{/if}}').should == [
      :TEXT, :START, :HASH, :IF, :PATH, :END,
      :TEXT, :START, :ELSE, :END,
      :TEXT, :START, :SLASH, :IF, :END, :EOS
    ]
  end

  it "scans inverse block tags using the unless syntax" do
    map_lex_type('foo {{#unless bar?}} hello {{/unless}}').should == [
      :TEXT, :START, :HASH, :UNLESS, :PATH, :END,
      :TEXT, :START, :SLASH, :UNLESS, :END, :EOS
    ]
  end

  it "scans inverse conditional block tags with the else token" do
    map_lex_type('foo {{#unless bar?}} hello {{else}} bye {{/unless}}').should == [
      :TEXT, :START, :HASH, :UNLESS, :PATH, :END,
      :TEXT, :START, :ELSE, :END,
      :TEXT, :START, :SLASH, :UNLESS, :END, :EOS
    ]
  end

  it "scans collection block tags with the each syntax" do
    map_lex_type('foo {{#each bar}} hello {{/each}}').should == [
      :TEXT, :START, :HASH, :EACH, :PATH, :END,
      :TEXT, :START, :SLASH, :EACH, :END, :EOS
    ]
  end

  it "treats quotes as text" do
    map_lex_type('"').should == [:TEXT, :EOS]
  end

  it "treats Ruby interpolation as text" do
    map_lex_type('#{foo}').should == [:TEXT, :EOS]
  end

  def lex(source)
    Curlybars::Lexer.lex(source)
  end

  def map_lex_type(source)
    lex(source).map(&:type)
  end
end
