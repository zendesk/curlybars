describe Curlybars::Lexer do
  describe "{{!-- ... --}}" do
    it "skips begin of block comment" do
      expect(lex('{{!--')).to produce []
    end

    it "skips begin and end of block comment" do
      expect(lex('{{!----}}')).to produce []
    end

    it "skips a comment block containing curlybar code" do
      expect(lex('{{!--{{helper}}--}}')).to produce []
    end

    it "is resilient to whitespaces" do
      expect(lex('{{!-- --}}')).to produce []
    end

    it "is resilient to newlines" do
      expect(lex("{{!--\n--}}")).to produce []
    end

    it "is skipped when present in plain text" do
      expect(lex('text {{!----}} text')).to produce [:TEXT, :TEXT]
    end
  end

  describe "{{! ... }}" do
    it "skips begin of block comment" do
      expect(lex('{{!')).to produce []
    end

    it "skips begin and end of block comment" do
      expect(lex('{{!}}')).to produce []
    end

    it "is resilient to whitespaces" do
      expect(lex('{{! }}')).to produce []
    end

    it "is resilient to newlines" do
      expect(lex("{{!\n}}")).to produce []
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{!}} text')).to produce [:TEXT, :TEXT]
    end
  end

  describe "{{<integer>}}" do
    it "is lexed as an integer" do
      expect(lex("{{7}}")).to produce [:START, :LITERAL, :END]
    end

    it "returns the expressed integer" do
      literal_token = lex("{{7}}").detect { |token| token.type == :LITERAL }
      expect(literal_token.value).to eq 7
    end
  end

  describe "{{<boolean>}}" do
    it "{{true}} is lexed as boolean" do
      expect(lex("{{true}}")).to produce [:START, :LITERAL, :END]
    end

    it "{{false}} is lexed as boolean" do
      expect(lex("{{false}}")).to produce [:START, :LITERAL, :END]
    end

    it "returns the expressed boolean" do
      literal_token = lex("{{true}}").detect { |token| token.type == :LITERAL }
      expect(literal_token.value).to be_truthy
    end
  end

  describe "{{''}}" do
    it "is lexed as a literal" do
      expect(lex("{{''}}")).to produce [:START, :LITERAL, :END]
    end

    it "returns the string between quotes" do
      literal_token = lex("{{'string'}}").detect { |token| token.type == :LITERAL }
      expect(literal_token.value).to eq '"string"'
    end

    it "is resilient to whitespaces" do
      expect(lex("{{ '' }}")).to produce [:START, :LITERAL, :END]
    end

    it "is lexed when present in plain text" do
      expect(lex("text {{''}} text")).to produce [:TEXT, :START, :LITERAL, :END, :TEXT]
    end
  end

  describe '{{""}}' do
    it "is lexed as a literal" do
      expect(lex('{{""}}')).to produce [:START, :LITERAL, :END]
    end

    it "returns the string between quotes" do
      literal_token = lex('{{"string"}}').detect { |token| token.type == :LITERAL }
      expect(literal_token.value).to eq '"string"'
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ "" }}')).to produce [:START, :LITERAL, :END]
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{""}} text')).to produce [:TEXT, :START, :LITERAL, :END, :TEXT]
    end
  end

  describe "{{@variable}}" do
    it "is lexed as a varaible" do
      expect(lex('{{@var}}')).to produce [:START, :VARIABLE, :END]
    end

    it "returns the identifier after `@`" do
      variable_token = lex('{{@var}}').detect { |token| token.type == :VARIABLE }
      expect(variable_token.value).to eq 'var'
    end

    it "returns the identifier after `@` also when using `../`" do
      variable_token = lex('{{@../var}}').detect { |token| token.type == :VARIABLE }
      expect(variable_token.value).to eq '../var'
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ @var }}')).to produce [:START, :VARIABLE, :END]
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{@var}} text')).to produce [:TEXT, :START, :VARIABLE, :END, :TEXT]
    end
  end

  describe "{{path context options}}" do
    it "is lexed with context and options" do
      expect(lex('{{path context key=value}}')).to produce [:START, :PATH, :PATH, :KEY, :PATH, :END]
    end

    it "is lexed without context" do
      expect(lex('{{path key=value}}')).to produce [:START, :PATH, :KEY, :PATH, :END]
    end

    it "is lexed without options" do
      expect(lex('{{path context}}')).to produce [:START, :PATH, :PATH, :END]
    end

    it "is lexed without context and options" do
      expect(lex('{{path}}')).to produce [:START, :PATH, :END]
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ path }}')).to produce [:START, :PATH, :END]
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{ path }} text')).to produce [:TEXT, :START, :PATH, :END, :TEXT]
    end
  end

  describe "{{path (path context options)}}" do
    it "is lexed with path, context and options" do
      expect(lex('{{path (path context key=value)}}')).to produce [:START, :PATH, :LPAREN, :PATH, :PATH, :KEY, :PATH, :RPAREN, :END]
    end

    it "is lexed without options" do
      expect(lex('{{path (path context)}}')).to produce [:START, :PATH, :LPAREN, :PATH, :PATH, :RPAREN, :END]
    end

    it "is lexed without context" do
      expect(lex('{{path (path key=value)}}')).to produce [:START, :PATH, :LPAREN, :PATH, :KEY, :PATH, :RPAREN, :END]
    end

    it "is lexed without context and options" do
      expect(lex('{{path (path)}}')).to produce [:START, :PATH, :LPAREN, :PATH, :RPAREN, :END]
    end

    it "is lexed with a nested subexpression" do
      expect(lex('{{path (path (path context key=value) key=value)}}')).to produce [:START, :PATH, :LPAREN, :PATH, :LPAREN, :PATH, :PATH, :KEY, :PATH, :RPAREN, :KEY, :PATH, :RPAREN, :END]
    end
  end

  describe "{{#if path}}...{{/if}}" do
    it "is lexed" do
      expect(lex('{{#if path}} text {{/if}}')).to produce(
        [:START, :HASH, :IF, :PATH, :END, :TEXT, :START, :SLASH, :IF, :END]
      )
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ # if path }} text {{/ if }}')).to produce(
        [:START, :HASH, :IF, :PATH, :END, :TEXT, :START, :SLASH, :IF, :END]
      )
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{#if path}} text {{/if}} text')).to produce(
        [:TEXT, :START, :HASH, :IF, :PATH, :END, :TEXT, :START, :SLASH, :IF, :END, :TEXT]
      )
    end
  end

  # rubocop:disable Layout/ArrayAlignment
  describe "{{#if path}}...{{else}}...{{/if}}" do
    it "is lexed" do
      expect(lex('{{#if path}} text {{else}} text {{/if}}')).to produce(
        [:START, :HASH, :IF, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :IF, :END]
      )
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ # if path }} text {{ else }} text {{/ if }}')).to produce(
        [:START, :HASH, :IF, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :IF, :END]
      )
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{#if path}} text {{else}} text {{/if}} text')).to produce(
        [:TEXT, :START, :HASH, :IF, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :IF, :END, :TEXT]
      )
    end
  end

  describe "{{#unless path}}...{{/unless}}" do
    it "is lexed" do
      expect(lex('{{#unless path}} text {{/unless}}')).to produce(
        [:START, :HASH, :UNLESS, :PATH, :END, :TEXT, :START, :SLASH, :UNLESS, :END]
      )
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ # unless path }} text {{/ unless }}')).to produce(
        [:START, :HASH, :UNLESS, :PATH, :END, :TEXT, :START, :SLASH, :UNLESS, :END]
      )
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{#unless path}} text {{/unless}} text')).to produce(
        [:TEXT, :START, :HASH, :UNLESS, :PATH, :END, :TEXT, :START, :SLASH, :UNLESS, :END, :TEXT]
      )
    end
  end

  describe "{{#unless path}}...{{else}}...{{/unless}}" do
    it "is lexed" do
      expect(lex('{{#unless path}} text {{else}} text {{/unless}}')).to produce(
        [:START, :HASH, :UNLESS, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :UNLESS, :END]
      )
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ # unless path }} text {{ else }} text {{/ unless }}')).to produce(
        [:START, :HASH, :UNLESS, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :UNLESS, :END]
      )
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{#unless path}} text {{else}} text {{/unless}} text')).to produce(
        [:TEXT, :START, :HASH, :UNLESS, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :UNLESS, :END, :TEXT]
      )
    end
  end

  describe "{{#each path}}...{{/each}}" do
    it "is lexed" do
      expect(lex('{{#each path}} text {{/each}}')).to produce(
        [:START, :HASH, :EACH, :PATH, :END, :TEXT, :START, :SLASH, :EACH, :END]
      )
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ # each path }} text {{/ each }}')).to produce(
        [:START, :HASH, :EACH, :PATH, :END, :TEXT, :START, :SLASH, :EACH, :END]
      )
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{#each path}} text {{/each}} text')).to produce(
        [:TEXT, :START, :HASH, :EACH, :PATH, :END, :TEXT, :START, :SLASH, :EACH, :END, :TEXT]
      )
    end
  end

  describe "{{#each path}}...{{else}}...{{/each}}" do
    it "is lexed" do
      expect(lex('{{#each path}} text {{else}} text {{/each}}')).to produce(
        [:START, :HASH, :EACH, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :EACH, :END]
      )
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ # each path }} text {{ else }} text {{/ each }}')).to produce(
        [:START, :HASH, :EACH, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :EACH, :END]
      )
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{#each path}} text {{else}} text {{/each}} text')).to produce(
        [:TEXT, :START, :HASH, :EACH, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :EACH, :END, :TEXT]
      )
    end
  end
  # rubocop:enable Layout/ArrayAlignment

  describe "{{#with path}}...{{/with}}" do
    it "is lexed" do
      expect(lex('{{#with path}} text {{/with}}')).to produce(
        [:START, :HASH, :WITH, :PATH, :END, :TEXT, :START, :SLASH, :WITH, :END]
      )
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ # with path }} text {{/ with }}')).to produce(
        [:START, :HASH, :WITH, :PATH, :END, :TEXT, :START, :SLASH, :WITH, :END]
      )
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{#with path}} text {{/with}} text')).to produce(
        [:TEXT, :START, :HASH, :WITH, :PATH, :END, :TEXT, :START, :SLASH, :WITH, :END, :TEXT]
      )
    end
  end

  describe "{{#path path options}}...{{/path}}" do
    it "is lexed with context and options" do
      expect(lex('{{#path context key=value}} text {{/path}}')).to produce(
        [:START, :HASH, :PATH, :PATH, :KEY, :PATH, :END, :TEXT, :START, :SLASH, :PATH, :END]
      )
    end

    it "is lexed without options" do
      expect(lex('{{#path context}} text {{/path}}')).to produce(
        [:START, :HASH, :PATH, :PATH, :END, :TEXT, :START, :SLASH, :PATH, :END]
      )
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ # path context key = value}} text {{/ path }}')).to produce(
        [:START, :HASH, :PATH, :PATH, :KEY, :PATH, :END, :TEXT, :START, :SLASH, :PATH, :END]
      )
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{#path context key=value}} text {{/path}} text')).to produce(
        [:TEXT, :START, :HASH, :PATH, :PATH, :KEY, :PATH, :END, :TEXT, :START, :SLASH, :PATH, :END, :TEXT]
      )
    end
  end

  describe "{{>path}}" do
    it "is lexed" do
      expect(lex('{{>path}}')).to produce [:START, :GT, :PATH, :END]
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ > path }}')).to produce [:START, :GT, :PATH, :END]
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{>path}} text')).to produce [:TEXT, :START, :GT, :PATH, :END, :TEXT]
    end
  end

  describe "when a leading backslash is present" do
    it "`{` is lexed as plain text" do
      expect(lex('\{')).to produce [:TEXT]
    end

    it "returns the original text" do
      text_token = lex('\{').detect { |token| token.type == :TEXT }
      expect(text_token.value).to eq '{'
    end

    it "is lexed when present in plain text" do
      expect(lex('text \{ text')).to produce [:TEXT, :TEXT, :TEXT]
    end
  end

  describe "can lex paths with or without leading `../`s" do
    it "`path` is lexed as a path" do
      expect(lex('{{path}}')).to produce [:START, :PATH, :END]
    end

    it "`../path` is lexed as a path" do
      expect(lex('{{../path}}')).to produce [:START, :PATH, :END]
    end

    it "`../../path` is lexed as a path" do
      expect(lex('{{../../path}}')).to produce [:START, :PATH, :END]
    end

    it "`path/../` raises an error" do
      expect do
        lex('{{path/../}}')
      end.to raise_error(RLTK::LexingError)
    end
  end

  describe "can lex paths with dashes" do
    it "`surrounded by other valid chars" do
      expect(lex('{{a-path}}')).to produce [:START, :PATH, :END]
    end

    it "at the beginning" do
      expect(lex('{{-path}}')).to produce [:START, :PATH, :END]
    end

    it "at the end" do
      expect(lex('{{path-}}')).to produce [:START, :PATH, :END]
    end
  end

  describe "can lex paths with identifiers that are numebrs" do
    it "`surrounded by other valid chars" do
      expect(lex('{{path.123}}')).to produce [:START, :PATH, :END]
    end
  end

  describe "outside a curlybar context" do
    it "`--}}` is lexed as plain text" do
      expect(lex('--}}')).to produce [:TEXT]
    end

    it "`}}` is lexed as plain text" do
      expect(lex('}}')).to produce [:TEXT]
    end

    it "`#` is lexed as plain text" do
      expect(lex('#')).to produce [:TEXT]
    end

    it "`/` is lexed as plain text" do
      expect(lex('/')).to produce [:TEXT]
    end

    it "`>` is lexed as plain text" do
      expect(lex('>')).to produce [:TEXT]
    end

    it "`if` is lexed as plain text" do
      expect(lex('if')).to produce [:TEXT]
    end

    it "`unless` is lexed as plain text" do
      expect(lex('unless')).to produce [:TEXT]
    end

    it "`each` is lexed as plain text" do
      expect(lex('each')).to produce [:TEXT]
    end

    it "`with` is lexed as plain text" do
      expect(lex('with')).to produce [:TEXT]
    end

    it "`else` is lexed as plain text" do
      expect(lex('else')).to produce [:TEXT]
    end

    it "a path is lexed as plain text" do
      expect(lex('this.is.a.path')).to produce [:TEXT]
    end

    it "an option is lexed as plain text" do
      expect(lex('key=value')).to produce [:TEXT]
    end
  end
end
