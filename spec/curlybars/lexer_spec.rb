describe Curlybars::Lexer do
  describe "{{!-- ... --}}" do
    it "skips begin of block comment" do
      lex('{{!--').should produce []
    end

    it "skips begin and end of block comment" do
      lex('{{!----}}').should produce []
    end

    it "skips a comment block containing curlybar code" do
      lex('{{!--{{helper}}--}}').should produce []
    end

    it "is resilient to whitespaces" do
      lex('{{!-- --}}').should produce []
    end

    it "is resilient to newlines" do
      lex("{{!--\n--}}").should produce []
    end

    it "is skipped when present in plain text" do
      lex('text {{!----}} text').should produce [:TEXT, :TEXT]
    end
  end

  describe "{{! ... }}" do
    it "skips begin of block comment" do
      lex('{{!').should produce []
    end

    it "skips begin and end of block comment" do
      lex('{{!}}').should produce []
    end

    it "is resilient to whitespaces" do
      lex('{{! }}').should produce []
    end
    it "is resilient to newlines" do
      lex("{{!\n}}").should produce []
    end

    it "is lexed when present in plain text" do
      lex('text {{!}} text').should produce [:TEXT, :TEXT]
    end
  end

  describe "{{<integer>}}" do
    it "is lexed as an integer" do
      lex("{{7}}").should produce [:START, :INTEGER, :END]
    end

    it "returns the expressed boolean" do
      integer_token = lex("{{7}}").detect {|token| token.type == :INTEGER}
      integer_token.value.should eq 7
    end
  end

  describe "{{<boolean>}}" do
    it "{{true}} is lexed as boolean" do
      lex("{{true}}").should produce [:START, :BOOLEAN, :END]
    end

    it "{{false}} is lexed as boolean" do
      lex("{{false}}").should produce [:START, :BOOLEAN, :END]
    end

    it "returns the expressed boolean" do
      boolean_token = lex("{{true}}").detect {|token| token.type == :BOOLEAN}
      boolean_token.value.should be_truthy
    end
  end

  describe "{{''}}" do
    it "is lexed as a string" do
      lex("{{''}}").should produce [:START, :STRING, :END]
    end

    it "returns the string between quotes" do
      string_token = lex("{{'string'}}").detect {|token| token.type == :STRING}
      string_token.value.should eq 'string'
    end

    it "is lexed when string is multiline" do
      lex("text {{'\n'}} text").should produce [:TEXT, :START, :STRING, :END, :TEXT]
    end

    it "is resilient to whitespaces" do
      lex("{{ '' }}").should produce [:START, :STRING, :END]
    end

    it "is lexed when present in plain text" do
      lex("text {{''}} text").should produce [:TEXT, :START, :STRING, :END, :TEXT]
    end
  end

  describe '{{""}}' do
    it "is lexed as a string" do
      lex('{{""}}').should produce [:START, :STRING, :END]
    end

    it "returns the string between quotes" do
      string_token = lex('{{"string"}}').detect {|token| token.type == :STRING}
      string_token.value.should eq 'string'
    end

    it "is lexed when string is multiline" do
      lex('text {{"\n"}} text').should produce [:TEXT, :START, :STRING, :END, :TEXT]
    end

    it "is resilient to whitespaces" do
      lex('{{ "" }}').should produce [:START, :STRING, :END]
    end

    it "is lexed when present in plain text" do
      lex('text {{""}} text').should produce [:TEXT, :START, :STRING, :END, :TEXT]
    end
  end

  describe "{{path context options}}" do
    it "is lexed with context and options" do
      lex('{{path context key=value}}').should produce [:START, :PATH, :PATH, :KEY, :PATH, :END]
    end

    it "is lexed without context" do
      lex('{{path key=value}}').should produce [:START, :PATH, :KEY, :PATH, :END]
    end

    it "is lexed without options" do
      lex('{{path context}}').should produce [:START, :PATH, :PATH, :END]
    end

    it "is lexed without context and options" do
      lex('{{path}}').should produce [:START, :PATH, :END]
    end

    it "is resilient to whitespaces" do
      lex('{{ path }}').should produce [:START, :PATH, :END]
    end

    it "is lexed when present in plain text" do
      lex('text {{ path }} text').should produce [:TEXT, :START, :PATH, :END, :TEXT]
    end
  end

  describe "{{#if path}}...{{/if}}" do
    it "is lexed" do
      lex('{{#if path}} text {{/if}}').should produce(
        [:START, :HASH, :IF, :PATH, :END, :TEXT, :START, :SLASH, :IF, :END])
    end

    it "is resilient to whitespaces" do
      lex('{{ # if path }} text {{/ if }}').should produce(
        [:START, :HASH, :IF, :PATH, :END, :TEXT, :START, :SLASH, :IF, :END])
    end

    it "is lexed when present in plain text" do
      lex('text {{#if path}} text {{/if}} text').should produce(
        [:TEXT, :START, :HASH, :IF, :PATH, :END, :TEXT, :START, :SLASH, :IF, :END, :TEXT])
    end
  end

  describe "{{#if path}}...{{else}}...{{/if}}" do
    it "is lexed" do
      lex('{{#if path}} text {{else}} text {{/if}}').should produce(
        [:START, :HASH, :IF, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :IF, :END])
    end

    it "is resilient to whitespaces" do
      lex('{{ # if path }} text {{ else }} text {{/ if }}').should produce(
        [:START, :HASH, :IF, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :IF, :END])
    end

    it "is lexed when present in plain text" do
      lex('text {{#if path}} text {{else}} text {{/if}} text').should produce(
        [:TEXT, :START, :HASH, :IF, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :IF, :END, :TEXT])
    end
  end

  describe "{{#unless path}}...{{/unless}}" do
    it "is lexed" do
      lex('{{#unless path}} text {{/unless}}').should produce(
        [:START, :HASH, :UNLESS, :PATH, :END, :TEXT, :START, :SLASH, :UNLESS, :END])
    end

    it "is resilient to whitespaces" do
      lex('{{ # unless path }} text {{/ unless }}').should produce(
        [:START, :HASH, :UNLESS, :PATH, :END, :TEXT, :START, :SLASH, :UNLESS, :END])
    end

    it "is lexed when present in plain text" do
      lex('text {{#unless path}} text {{/unless}} text').should produce(
        [:TEXT, :START, :HASH, :UNLESS, :PATH, :END, :TEXT, :START, :SLASH, :UNLESS, :END, :TEXT])
    end
  end

  describe "{{#unless path}}...{{else}}...{{/unless}}" do
    it "is lexed" do
      lex('{{#unless path}} text {{else}} text {{/unless}}').should produce(
        [:START, :HASH, :UNLESS, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :UNLESS, :END])
    end

    it "is resilient to whitespaces" do
      lex('{{ # unless path }} text {{ else }} text {{/ unless }}').should produce(
        [:START, :HASH, :UNLESS, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :UNLESS, :END])
    end

    it "is lexed when present in plain text" do
      lex('text {{#unless path}} text {{else}} text {{/unless}} text').should produce(
        [:TEXT, :START, :HASH, :UNLESS, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :UNLESS, :END, :TEXT])
    end
  end

  describe "{{#each path}}...{{/each}}" do
    it "is lexed" do
      lex('{{#each path}} text {{/each}}').should produce(
        [:START, :HASH, :EACH, :PATH, :END, :TEXT, :START, :SLASH, :EACH, :END])
    end

    it "is resilient to whitespaces" do
      lex('{{ # each path }} text {{/ each }}').should produce(
        [:START, :HASH, :EACH, :PATH, :END, :TEXT, :START, :SLASH, :EACH, :END])
    end

    it "is lexed when present in plain text" do
      lex('text {{#each path}} text {{/each}} text').should produce(
        [:TEXT, :START, :HASH, :EACH, :PATH, :END, :TEXT, :START, :SLASH, :EACH, :END, :TEXT])
    end
  end

  describe "{{#each path}}...{{else}}...{{/each}}" do
    it "is lexed" do
      lex('{{#each path}} text {{else}} text {{/each}}').should produce(
        [:START, :HASH, :EACH, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :EACH, :END])
    end

    it "is resilient to whitespaces" do
      lex('{{ # each path }} text {{ else }} text {{/ each }}').should produce(
        [:START, :HASH, :EACH, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :EACH, :END])
    end

    it "is lexed when present in plain text" do
      lex('text {{#each path}} text {{else}} text {{/each}} text').should produce(
        [:TEXT, :START, :HASH, :EACH, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :EACH, :END, :TEXT])
    end
  end

  describe "{{#with path}}...{{/with}}" do
    it "is lexed" do
      lex('{{#with path}} text {{/with}}').should produce(
        [:START, :HASH, :WITH, :PATH, :END, :TEXT, :START, :SLASH, :WITH, :END])
    end

    it "is resilient to whitespaces" do
      lex('{{ # with path }} text {{/ with }}').should produce(
        [:START, :HASH, :WITH, :PATH, :END, :TEXT, :START, :SLASH, :WITH, :END])
    end

    it "is lexed when present in plain text" do
      lex('text {{#with path}} text {{/with}} text').should produce(
        [:TEXT, :START, :HASH, :WITH, :PATH, :END, :TEXT, :START, :SLASH, :WITH, :END, :TEXT])
    end
  end

  describe "{{#path path options}}...{{/path}}" do
    it "is lexed with context and options" do
      lex('{{#path context key=value}} text {{/path}}').should produce(
        [:START, :HASH, :PATH, :PATH, :KEY, :PATH, :END, :TEXT, :START, :SLASH, :PATH, :END])
    end

    it "is lexed without options" do
      lex('{{#path context}} text {{/path}}').should produce(
        [:START, :HASH, :PATH, :PATH, :END, :TEXT, :START, :SLASH, :PATH, :END])
    end

    it "is resilient to whitespaces" do
      lex('{{ # path context key = value}} text {{/ path }}').should produce(
        [:START, :HASH, :PATH, :PATH, :KEY, :PATH, :END, :TEXT, :START, :SLASH, :PATH, :END])
    end

    it "is lexed when present in plain text" do
      lex('text {{#path context key=value}} text {{/path}} text').should produce(
        [:TEXT, :START, :HASH, :PATH, :PATH, :KEY, :PATH, :END, :TEXT, :START, :SLASH, :PATH, :END, :TEXT])
    end
  end

  describe "{{>path}}" do
    it "is lexed" do
      lex('{{>path}}').should produce [:START, :GT, :PATH, :END]
    end

    it "is resilient to whitespaces" do
      lex('{{ > path }}').should produce [:START, :GT, :PATH, :END]
    end

    it "is lexed when present in plain text" do
      lex('text {{>path}} text').should produce [:TEXT, :START, :GT, :PATH, :END, :TEXT]
    end
  end

  describe "when a leading backslash is present" do
    it "`{` is lexed as plain text" do
      lex('\{').should produce [:TEXT]
    end

    it "returns the original text" do
      text_token = lex('\{').detect {|token| token.type == :TEXT}
      text_token.value.should eq '{'
    end

    it "is lexed when present in plain text" do
      lex('text \{ text').should produce [:TEXT, :TEXT, :TEXT]
    end
  end

  describe "outside a curlybar context" do
    it "`--}}` is lexed as plain text" do
      lex('--}}').should produce [:TEXT]
    end

    it "`}}` is lexed as plain text" do
      lex('}}').should produce [:TEXT]
    end

    it "`#` is lexed as plain text" do
      lex('#').should produce [:TEXT]
    end

    it "`/` is lexed as plain text" do
      lex('/').should produce [:TEXT]
    end

    it "`>` is lexed as plain text" do
      lex('>').should produce [:TEXT]
    end

    it "`if` is lexed as plain text" do
      lex('if').should produce [:TEXT]
    end

    it "`unless` is lexed as plain text" do
      lex('unless').should produce [:TEXT]
    end

    it "`each` is lexed as plain text" do
      lex('each').should produce [:TEXT]
    end

    it "`with` is lexed as plain text" do
      lex('with').should produce [:TEXT]
    end

    it "`else` is lexed as plain text" do
      lex('else').should produce [:TEXT]
    end

    it "a path is lexed as plain text" do
      lex('this.is.a.path').should produce [:TEXT]
    end

    it "an option is lexed as plain text" do
      lex('key=value').should produce [:TEXT]
    end
  end
end
