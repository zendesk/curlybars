describe "{{(helper arg1 arg2 ... key=value ...)}}" do
  let(:global_helpers_providers) { [IntegrationTest::GlobalHelperProvider.new] }

  describe "#compile" do
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context")) }

    it "can be an argument to helpers" do
      template = Curlybars.compile(<<-HBS)
        {{global_helper (global_helper 'argument' option='value') option='value'}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        argument - option:value - option:value
      HTML
    end

    it "can be an argument to itself" do
      template = Curlybars.compile(<<-HBS)
        {{global_helper (global_helper (global_helper 'a' option='b') option='c') option='d'}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        a - option:b - option:c - option:d
      HTML
    end

    it "can handle data objects as argument" do
      template = Curlybars.compile(<<-HBS)
        {{global_helper (extract user attribute='first_name') option='value'}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        Libo - option:value
      HTML
    end

    it "can handle calls inside with" do
      template = Curlybars.compile(<<-HBS)
        {{#with article}}
          {{global_helper (extract author attribute='first_name') option='value'}}
        {{/with}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        Nicolò - option:value
      HTML
    end

    it "can handle collections as arguments" do
      template = Curlybars.compile(<<-HBS)
        {{join (filter articles on='title' starts_with="A") attribute='title' separator='-'}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        A1-A2
      HTML
    end

    it "does not accept subexpressions in the root" do
      expect do
        Curlybars.compile(<<-HBS)
          {{(join articles attribute='title' separator='-'}}
        HBS
      end.to raise_error(Curlybars::Error::Parse)
    end

    it "can be called within if expressions" do
      template = Curlybars.compile(<<-HBS)
        {{#if (calc 3 ">" 1)}}
          True
        {{/if}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        True
      HTML
    end

    # Replication of Handlebars' subexpression specs for feature parity
    # https://github.com/handlebars-lang/handlebars.js/blob/1a08e1d0a7f500f2c1188cbd21750bb9180afcbb/spec/subexpressions.js

    it "arg-less helper" do
      template = Curlybars.compile(<<-HBS)
        {{foo (bar)}}!
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        LOLLOL!
      HTML
    end

    context "with blog presenter" do
      let(:presenter) do
        IntegrationTest::BlogPresenter.new(
          lambda { |*args, options|
            val = args.first
            "val is #{val}"
          }
        )
      end

      it "helper w args" do
        template = Curlybars.compile(<<-HBS)
          {{blog (equal a b)}}
        HBS

        expect(eval(template)).to resemble(<<-HTML)
          val is true
        HTML
      end

      it "supports much nesting" do
        template = Curlybars.compile(<<-HBS)
          {{blog (equal (equal true true) true)}}
        HBS

        expect(eval(template)).to resemble(<<-HTML)
          val is true
        HTML
      end

      it "with hashes" do
        template = Curlybars.compile(<<-HBS)
          {{blog (equal (equal true true) true fun='yes')}}
        HBS

        expect(eval(template)).to resemble(<<-HTML)
          val is true
        HTML
      end
    end

    context "with a different blog presenter" do
      let(:presenter) do
        IntegrationTest::BlogPresenter.new(
          lambda { |*args, options|
            "val is #{options[:fun]}"
          }
        )
      end

      it "as hashes" do
        template = Curlybars.compile(<<-HBS)
          {{blog fun=(equal (blog fun=1) 'val is 1')}}
        HBS

        expect(eval(template)).to resemble(<<-HTML)
          val is true
        HTML
      end
    end

    context "with yet another blog presenter" do
      let(:presenter) do
        IntegrationTest::BlogPresenter.new(
          lambda { |*args, options|
            first, second, third = args
            "val is #{first}, #{second} and #{third}"
          }
        )
      end

      it "mixed paths and helpers" do
        template = Curlybars.compile(<<-HBS)
          {{blog baz.bat (equal a b) baz.bar}}
        HBS

        expect(eval(template)).to resemble(<<-HTML)
          val is foo!, true and bar!
        HTML
      end
    end

    describe "GH-800 : Complex subexpressions" do
      let(:presenter) do
        IntegrationTest::LetterPresenter.new(
          a: 'a', b: 'b', c: { c: 'c' }, d: 'd', e: { e: 'e' }
        )
      end

      it "can handle complex subexpressions" do
        inputs = [
          "{{dash 'abc' (concat a b)}}",
          "{{dash d (concat a b)}}",
          "{{dash c.c (concat a b)}}",
          "{{dash (concat a b) c.c}}",
          "{{dash (concat a e.e) c.c}}"
        ]

        expected_results = [
          "abc-ab",
          "d-ab",
          "c-ab",
          "ab-c",
          "ae-c"
        ]

        aggregate_failures do
          inputs.each_with_index do |input, i|
            expect(eval(Curlybars.compile(input))).to resemble(expected_results[i])
          end
        end
      end
    end

    it "multiple subexpressions in a hash" do
      template = Curlybars.compile(<<-HBS)
        {{input aria-label=(t "Name") placeholder=(t "Example User")}}
      HBS

      expected_output = '<input aria-label="Name" placeholder="Example User" />'
                        .gsub("<", "&lt;")
                        .gsub(">", "&gt;")
                        .gsub('"', "&quot;")

      expect(eval(template)).to resemble(expected_output)
    end

    context "with item show presenter" do
      let(:presenter) do
        IntegrationTest::ItemShowPresenter.new(field: "Name", placeholder: "Example User")
      end

      it "multiple subexpressions in a hash with context" do
        template = Curlybars.compile(<<-HBS)
          {{input aria-label=(t item.field) placeholder=(t item.placeholder)}}
        HBS

        expected_output = '<input aria-label="Name" placeholder="Example User" />'
                          .gsub("<", "&lt;")
                          .gsub(">", "&gt;")
                          .gsub('"', "&quot;")

        expect(eval(template)).to resemble(expected_output)
      end
    end
  end
end
