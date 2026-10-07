# Curlybars

Curlybars is a Ruby gem implementing a subset of the Handlebars templating language for Rails applications. It uses a presenter pattern (inspired by the Curly gem) to provide type-safe, whitelisted context to templates. Templates use `.hbs` extensions and are validated at development time before rendering.

## Setup & Commands

```bash
# Install dependencies
bundle install

# Run all tests
bundle exec rspec

# Run a single test file
bundle exec rspec spec/curlybars/lexer_spec.rb

# Run linter
bundle exec rubocop

# Run both tests and linting (default task)
bundle exec rake

# Run tests against a specific Rails gemfile
BUNDLE_GEMFILE=gemfiles/rails8.1.gemfile bundle exec rspec
```

## Code Conventions

- Follow RuboCop rules configured in `.rubocop.yml` (plugins: performance, rake, rspec, rspec_rails)
- Use `frozen_string_literal: true` magic comment at the top of files
- Error classes inherit from `Curlybars::Error::Base` and live in `lib/curlybars/error/`
- AST node classes live in `lib/curlybars/node/`; each node responds to `.compile` and `.validate`
- New node types must be registered in `lib/curlybars/parser.rb` and required in `lib/curlybars.rb`
- Processors implement `.process!(tokens, identifier)` and live in `lib/curlybars/processor/`
- Use `extend Curlybars::MethodWhitelist` (not inheritance) for PORO presenters; subclass `Curlybars::Presenter` only for root presenters
- Configuration keys are added to `Curlybars::Configuration` with accessor and a sensible default in `#initialize`

## Testing

- Framework: RSpec (see `spec/spec_helper.rb`)
- `spec/curlybars/` — unit tests mirroring `lib/curlybars/`
- `spec/acceptance/` — acceptance tests for template features (use integration helpers)
- `spec/integration/` — integration tests using the Rails dummy app at `spec/dummy/`
- `spec/matchers/` — custom RSpec matchers shared across suites
- Always add tests covering the `compile`, `validate`, and `render` phases for new language features
- Use `bundle exec rspec spec/path/to_spec.rb` to run a focused test

## Do

- Use `allow_methods` to explicitly whitelist methods on presenters — this is a security boundary
- Add both positive and negative test cases when implementing new node types or error conditions
- Use `Curlybars::Error::Base` subclasses with a unique `id` string for all error types
- Use `ActiveSupport::Notifications` instruments (`compile.curlybars`) for observability
- Configure runtime limits (`output_limit`, `rendering_timeout`) in the Rails initializer
- Register new template language features (nodes, processors) via the configuration extension points
- Use `Curlybars::Generic` as the return type annotation for helpers whose output type is dynamic

## Don't

- Don't expose presenter methods without explicitly whitelisting them via `allow_methods` — the whitelist is a security control
- Don't call `Curlybars::Lexer`, `Curlybars::Parser`, or AST node internals directly from application code — use the `Curlybars.compile`, `Curlybars.validate`, and `Curlybars.visit` public API
- Don't add arbitrary Ruby evaluation or metaprogramming that could bypass the method whitelist
- Don't modify `Gemfile.lock` directly — run `bundle install`; update per-Rails gemfile locks in `gemfiles/`
- Don't hardcode Rails or Ruby version constraints in new code — check `curlybars.gemspec` and `gemfiles/` for the tested matrix
- Don't use `eval` or `exec` with user-supplied template content outside the controlled compilation pipeline

## Architecture

See `ARCHITECTURE.md` for component map, compilation pipeline, and design decisions.

## Security

See `SECURITY.md` for mandatory security requirements, prohibited patterns, and escalation triggers.

## Safety & Permissions

Allowed without approval:
- Read/list files
- Run single-file tests (`bundle exec rspec spec/path/to_spec.rb`)
- Run RuboCop on specific files

Ask before:
- Installing or removing gems (modifying `Gemfile` or `curlybars.gemspec`)
- Deleting files or directories
- Running the full test matrix across all gemfiles
- Modifying CI/CD workflows in `.github/workflows/`
- Pushing to remote branches or updating `lib/curlybars/version.rb` (triggers a publish)

## PR & Commit Guidelines

- PR titles: plain English, imperative mood (e.g., "Add support for inline partials")
- Commit messages: short summary (50 chars max), blank line, then longer description if needed
- No ticket number format required; see CONTRIBUTING.md for full guidelines
- Releasing: update `lib/curlybars/version.rb` and `CHANGELOG.md`, update all `gemfiles/*.lock` files, then merge to `main` — the publish workflow fires automatically

## References

- Architecture: `ARCHITECTURE.md`
- Security: `SECURITY.md`
- Contributing: `CONTRIBUTING.md`
- Template language spec: `docs/templates.md`
- Presenter documentation: `docs/presenters.md`
- Helpers documentation: `docs/helpers.md`
- Configuration options: `docs/configuration.md`
- Error reference: `docs/errors.md`
