In order to keep the Curlybars code base nice and tidy, please observe these best practises when making contributions:

- Add tests for all your code. Make sure the tests are clear and fail with proper error messages. It's a good idea to let your test fail in order to review whether the message makes sense; then make the test pass.
- Document any unclear things in the code. Even better, don't make the code do unclear things.
- Use the coding style already present in the code base.
- Make your commit messages precise and to the point. Add a short summary (50 chars max) followed by a blank line and then a longer description, if necessary, e.g.

### Benchmarks
`bundle exec rake benchmark` measures lexing, parsing, compiling, `eval` and rendering of the templates in `benchmark/templates`, both directly and through ActionView. It takes a few minutes, and writes:

- [`benchmark/RESULTS.md`](benchmark/RESULTS.md): the results, and the machine and versions they were generated on.
- `benchmark/results.json`: the same results in a machine-readable form.
- [`benchmark/HISTORY.md`](benchmark/HISTORY.md): charts and tables of every version of `results.json` in the git history, plus the new one. `bundle exec rake benchmark:history` regenerates it without running the benchmark.

To run the current benchmark against an earlier version, e.g. a release tag, use `bundle exec rake 'benchmark:ref[v1.16.1]'`. Templates that the version can't render are skipped (Curlybars 1.15.0 has no partial providers, so it only renders the small template).

Times depend on the machine, so `HISTORY.md` only compares them between runs on the same machine. Allocations per call don't depend on the machine. To see the effect of a change, run the benchmark before and after it on the same machine, and commit the three files with the change.

### Releasing a new version
A new version is published to RubyGems.org every time a change to `version.rb` is pushed to the `main` branch.
In short, follow these steps:
1. Update `version.rb`,
2. update version in all `Gemfile.lock` files,
3. merge this change into `main`, and
4. look at [the action](https://github.com/zendesk/curlybars/actions/workflows/publish.yml) for output.

To create a pre-release from a non-main branch:
1. change the version in `version.rb` to something like `1.2.0.pre.1` or `2.0.0.beta.2`,
2. push this change to your branch,
3. go to [Actions → “Publish to RubyGems.org” on GitHub](https://github.com/zendesk/curlybars/actions/workflows/publish.yml),
4. click the “Run workflow” button,
5. pick your branch from a dropdown.
