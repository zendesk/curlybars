describe "PathFinder" do
  let(:source) do
    <<-HBS
        {{user.name}}
        {{user.avatar.url}}

        {{#print_helper user.settings first='value' second=user.role}}
        {{/print_helper}}

        {{calc (math user.score "+" 10) "*" 2}}

        {{#render_inverse user.premium}}
          Premium content
        {{else}}
          Free content {{user.name}}
        {{/render_inverse}}

        {{#each user.posts}}
          {{title}}
          {{author.name}}
          {{#each comments}}
            {{body}}
            {{../title}}
            {{author.avatar}}
          {{/each}}
        {{/each}}

        {{#if user.active}}
          Active user
          {{#if user.verified}}
            Verified
          {{else}}
            {{user.status}}
          {{/if}}
        {{/if}}

        {{#unless user.banned}}
          Welcome {{user.name}}
        {{/unless}}

        {{> partial}}

        {{#with user}}
          {{name}}
          {{avatar.url}}
          {{#with settings}}
            {{theme}}
            {{../name}}
          {{/with}}
        {{/with}}

        {{product.price}}
        {{product.category.name}}
    HBS
  end

  describe "BlockHelperElse nodes" do
    it "finds matches in node arguments" do
      matches = Curlybars.find("user.settings", source)
      expect(matches.count).to eq(2)
    end

    it "returns correct paths including context changes" do
      matches = Curlybars.find("user.settings", source)
      expect(matches.map(&:path)).to contain_exactly("user.settings", "settings")
    end
  end

  describe "BlockHelperElse node helper templates" do
    it "finds matches in helper templates" do
      matches = Curlybars.find("user.premium", source)
      expect(matches.count).to eq(1)
    end

    it "returns correct path" do
      matches = Curlybars.find("user.premium", source)
      expect(matches.map(&:path)).to eq(["user.premium"])
    end
  end

  describe "BlockHelperElse node else templates" do
    it "finds matches in else templates" do
      matches = Curlybars.find("user.name", source)
      expect(matches.count).to eq(5)
    end

    it "returns correct paths including context changes" do
      matches = Curlybars.find("user.name", source)
      expect(matches.map(&:path)).to contain_exactly("user.name", "user.name", "user.name", "name", "../name")
    end
  end

  describe "EachElse nodes" do
    it "finds matches in each node paths" do
      matches = Curlybars.find("user.posts", source)
      expect(matches.count).to eq(1)
    end

    it "returns correct path" do
      matches = Curlybars.find("user.posts", source)
      expect(matches.map(&:path)).to eq(["user.posts"])
    end
  end

  describe "EachElse each templates with context changes" do
    it "finds matches with context changes" do
      matches = Curlybars.find("user.posts.title", source)
      expect(matches.count).to eq(2)
    end

    it "returns correct paths" do
      matches = Curlybars.find("user.posts.title", source)
      expect(matches.map(&:path)).to contain_exactly("title", "../title")
    end
  end

  describe "nested EachElse nodes" do
    it "finds matches in nested contexts" do
      matches = Curlybars.find("user.posts.comments.body", source)
      expect(matches.count).to eq(1)
    end

    it "returns correct path" do
      matches = Curlybars.find("user.posts.comments.body", source)
      expect(matches.map(&:path)).to eq(["body"])
    end
  end

  describe "IfElse nodes" do
    it "finds matches in if conditions" do
      matches = Curlybars.find("user.active", source)
      expect(matches.count).to eq(1)
    end

    it "returns correct path" do
      matches = Curlybars.find("user.active", source)
      expect(matches.map(&:path)).to eq(["user.active"])
    end
  end

  describe "nested IfElse nodes" do
    it "finds matches in nested if conditions" do
      matches = Curlybars.find("user.verified", source)
      expect(matches.count).to eq(1)
    end

    it "returns correct path" do
      matches = Curlybars.find("user.verified", source)
      expect(matches.map(&:path)).to eq(["user.verified"])
    end
  end

  describe "IfElse else templates" do
    it "finds matches in else branches" do
      matches = Curlybars.find("user.status", source)
      expect(matches.count).to eq(1)
    end

    it "returns correct path" do
      matches = Curlybars.find("user.status", source)
      expect(matches.map(&:path)).to eq(["user.status"])
    end
  end

  describe "UnlessElse nodes" do
    it "finds matches in unless conditions" do
      matches = Curlybars.find("user.banned", source)
      expect(matches.count).to eq(1)
    end

    it "returns correct path" do
      matches = Curlybars.find("user.banned", source)
      expect(matches.map(&:path)).to eq(["user.banned"])
    end
  end

  describe "WithElse nodes" do
    it "finds matches in with paths" do
      matches = Curlybars.find("user", source)
      expect(matches.count).to eq(1)
    end

    it "returns correct path" do
      matches = Curlybars.find("user", source)
      expect(matches.map(&:path)).to eq(["user"])
    end
  end

  describe "WithElse templates with context changes" do
    it "finds matches with context changes" do
      matches = Curlybars.find("user.avatar.url", source)
      expect(matches.count).to eq(2)
    end

    it "returns correct paths" do
      matches = Curlybars.find("user.avatar.url", source)
      expect(matches.map(&:path)).to contain_exactly("user.avatar.url", "avatar.url")
    end
  end

  describe "nested WithElse nodes" do
    it "finds matches in nested with contexts" do
      matches = Curlybars.find("user.settings.theme", source)
      expect(matches.count).to eq(1)
    end

    it "returns correct path" do
      matches = Curlybars.find("user.settings.theme", source)
      expect(matches.map(&:path)).to eq(["theme"])
    end
  end

  describe "SubExpression nodes" do
    it "finds matches in subexpressions" do
      matches = Curlybars.find("user.score", source)
      expect(matches.count).to eq(1)
    end

    it "returns correct path" do
      matches = Curlybars.find("user.score", source)
      expect(matches.map(&:path)).to eq(["user.score"])
    end
  end

  describe "Option nodes" do
    it "finds matches in helper options" do
      matches = Curlybars.find("user.role", source)
      expect(matches.count).to eq(1)
    end

    it "returns correct path" do
      matches = Curlybars.find("user.role", source)
      expect(matches.map(&:path)).to eq(["user.role"])
    end
  end

  describe "Partial nodes" do
    it "finds matches in partial paths" do
      matches = Curlybars.find("partial", source)
      expect(matches.count).to eq(1)
    end

    it "returns correct path" do
      matches = Curlybars.find("partial", source)
      expect(matches.map(&:path)).to eq(["partial"])
    end
  end

  describe "Output nodes" do
    it "finds matches in output values" do
      matches = Curlybars.find("product.price", source)
      expect(matches.count).to eq(1)
    end

    it "returns correct path" do
      matches = Curlybars.find("product.price", source)
      expect(matches.map(&:path)).to eq(["product.price"])
    end
  end

  describe "nested paths" do
    it "finds matches for deeply nested paths" do
      matches = Curlybars.find("product.category.name", source)
      expect(matches.count).to eq(1)
    end

    it "returns correct path" do
      matches = Curlybars.find("product.category.name", source)
      expect(matches.map(&:path)).to eq(["product.category.name"])
    end
  end

  describe "multiple contexts" do
    it "finds matches across different contexts" do
      matches = Curlybars.find("user.posts.author.name", source)
      expect(matches.count).to eq(1)
    end

    it "returns correct path" do
      matches = Curlybars.find("user.posts.author.name", source)
      expect(matches.map(&:path)).to eq(["author.name"])
    end
  end

  describe "parent navigation in nested contexts" do
    it "finds matches with parent references" do
      matches = Curlybars.find("user.posts.comments.author.avatar", source)
      expect(matches.count).to eq(1)
    end

    it "returns correct path" do
      matches = Curlybars.find("user.posts.comments.author.avatar", source)
      expect(matches.map(&:path)).to eq(["author.avatar"])
    end
  end

  describe "regression tests" do
    let(:template) do
      <<-HBS
          {{breadcrumbs}}

          {{section.name}}

          {{#if section.internal}} Internal {{else}} {{breadcrumbs}} {{/if}}

          {{#each section.sections}}
            {{name}}
          {{/each}}

          {{#with section}}
            {{name}}
            {{#if internal}} Internal {{/if}}
            {{#each sections}}
              {{../name}}
              {{name}}
            {{/each}}
          {{/with}}

          {{article.title}}
          {{article.author.url}}

          {{#with article}}
            {{#with author}}
              {{url}}
              {{#each organizations}}
                {{../../title}}
                {{id}}
              {{/each}}
            {{/with}}
          {{/with}}
      HBS
    end

    describe "searching for breadcrumbs" do
      it "finds 2 matches" do
        matches = Curlybars.find("breadcrumbs", template)
        expect(matches.count).to eq(2)
      end

      it "returns correct paths" do
        matches = Curlybars.find("breadcrumbs", template)
        expect(matches.map(&:path)).to eq(["breadcrumbs", "breadcrumbs"])
      end
    end

    describe "searching for section.name" do
      it "finds 3 matches" do
        matches = Curlybars.find("section.name", template)
        expect(matches.count).to eq(3)
      end

      it "returns correct paths" do
        matches = Curlybars.find("section.name", template)
        expect(matches.map(&:path)).to eq(["section.name", "name", "../name"])
      end
    end

    describe "searching for section.internal" do
      it "finds 2 matches" do
        matches = Curlybars.find("section.internal", template)
        expect(matches.count).to eq(2)
      end

      it "returns correct paths" do
        matches = Curlybars.find("section.internal", template)
        expect(matches.map(&:path)).to eq(["section.internal", "internal"])
      end
    end

    describe "searching for section.sections.name" do
      it "finds 2 matches" do
        matches = Curlybars.find("section.sections.name", template)
        expect(matches.count).to eq(2)
      end

      it "returns correct paths" do
        matches = Curlybars.find("section.sections.name", template)
        expect(matches.map(&:path)).to eq(["name", "name"])
      end
    end

    describe "searching for article.title" do
      it "finds 2 matches" do
        matches = Curlybars.find("article.title", template)
        expect(matches.count).to eq(2)
      end

      it "returns correct paths" do
        matches = Curlybars.find("article.title", template)
        expect(matches.map(&:path)).to eq(["article.title", "../../title"])
      end
    end

    describe "searching for article.author.url" do
      it "finds 2 matches" do
        matches = Curlybars.find("article.author.url", template)
        expect(matches.count).to eq(2)
      end

      it "returns correct paths" do
        matches = Curlybars.find("article.author.url", template)
        expect(matches.map(&:path)).to eq(["article.author.url", "url"])
      end
    end

    describe "searching for article.author.organizations.id" do
      it "finds 1 match" do
        matches = Curlybars.find("article.author.organizations.id", template)
        expect(matches.count).to eq(1)
      end

      it "returns correct path" do
        matches = Curlybars.find("article.author.organizations.id", template)
        expect(matches.map(&:path)).to eq(["id"])
      end
    end
  end
end
