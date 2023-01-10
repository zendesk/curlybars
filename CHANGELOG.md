### Unreleased

* Remove support for Ruby 2.4 and 2.5.

### Curlybars 1.8.0 (November 9, 2022)
* Add testing with Ruby 2.7, 3.0 & 3.1
* Add support for Rails 7.0

### Curlybars 1.7.0 (February 17, 2021)
* Add language support for subexpressions in `#each` and `#with`
* Introduce the concept of generic object and collection helpers

### Curlybars 1.6.0 (January 05, 2021)
* Use GitHub Actions for testing.
* Add support for Rails 6.0 and 6.1.

### Curlybars 1.5.1 (November 02, 2020)
* Add missing visitor for the subexpression node

### Curlybars 1.5.0 (October 27, 2020)
* Add basic language support subexpressions (save for `#each`)

### Curlybars 1.4.0 (September 29, 2020)
* Allow arg-less helpers in if/unless conditions

### Curlybars 1.3.1 (January 13, 2020)
* Memoize allowed_methods

### Curlybars 1.3.0 (December 17, 2019)
* Allow context-based method whitelisting

### Curlybars 1.2.1 (November 13, 2019)
* Validate out of scope access

### Curlybars 1.2.0 (March 15, 2019)

* Add support for traversing Curlybars AST via `Curlybars.visit`

### Curlybars 1.1.4 (Oct 25, 2018)

* Drop support for CacheDigests
* Testing improvements

### Curlybars 1.1.3 (Oct 2, 2018)

* Cache Curlybars compilations

### Curlybars 1.1.2 (Aug 29, 2018)

* BUGFIX: Literals and variables in if statement condition validate correctly

### Curlybars 1.1.1 (Aug 16, 2018)

* Disallow helpers in if conditions

### Curlybars 1.1.0 (May 23, 2018)

* Add support for Rails 5.2.

### Curlybars 1.0.0 (January 23, 2018)

* Use Circle CI for testing.
* Remove unneeded gem dependencies.
* Fix outstanding RuboCop issues.

### Curlybars 0.9.13 (January 11, 2018)

* Fix the licence value in gemspec
* Update some Rubocop config and code style
* Remove unnecessary rspec config
* Compatibility with Bundler v1.16.0

### Curlybars 0.9.12 (October 30, 2017)

* BUGFIX: Caching of {{#each}} for empty templates
* BUGFIX: {{#each}} would leave contexts and variables in wrong state

### Curlybars 0.9.11 (October 25, 2017)

* Add support for PORO presenter caching with {{#each}}

### Curlybars 0.9.10 (July 27, 2017)

* Support defining allow_methods at runtime

### Curlybars 0.9.9 (June 28, 2017)

* BUGFIX: Error position has 0 as length default value (before was nil)

### Curlybars 0.9.8 (June 22, 2017)

* Embed length of validation error in position object
* BUGFIX: return a Curlybars::Position instance during validation

### Curlybars 0.9.7 (April 29, 2017)

* Drop support for Rails 4.1.
* Add support for Rails 5.1.

### Curlybars 0.9.5 (February 7, 2017)

* Loosen dependency restrictions on FFI and RLTK.

### Curlybars 0.9.4 (December 22, 2016)

* Change `DependencyTracker.call` to returns array, for compatibility with Rails 5.0.

### Curlybars 0.9.0 (April 29, 2015)

* Changed signature of `Curlybars.validate`, now using a directly a dependency tree

### Curlybars 0.8.0 (April 28, 2015)

* Remove support for :deprecated methods

### Curlybars 0.5.13 (June 18, 2015)

* Add support for compiler transformers

  Libo Cannici & Mauro Codella

### Curlybars 0.5.4 (May 11, 2015)

* Expose metadata in some exceptions

  Libo Cannici & Mauro Codella

### Curlybars 0.5.1 (May 4, 2015)

* Token factory API to be used in pre-processors

  Libo Cannici & Mauro Codella

### Curlybars 0.5.0 (May 4, 2015)

* Support for custom pre-processors

  Libo Cannici & Mauro Codella

### Curlybars 0.4.12 (April 29, 2015)

* Differentiate partials from helpers during validation

  Libo Cannici & Mauro Codella

### Curlybars 0.4.12 (April 28, 2015)

* Update dependency of Curly

  Libo Cannici

### Curlybars 0.4.12 (April 8, 2015)

* Lexer fixes

  Mauro Codella

### Curlybars 0.4.11 (April 8, 2015)

* Security constraints

  Mauro Codella

### Curlybars 0.4.10 (March 19, 2015)

* Cache presenter methods calls, when not helpers
* Make nesting/traversing checks configurable

  Mauro Codella
  Libo Cannici

### Curlybars 0.4.9 (March 19, 2015)

* Custom variables in block helpers
* Each and EachElse can iterate over Hashes

  Mauro Codella

### Curlybars 0.4.8 (March 16, 2015)

* Pin FFI dependency to 1.9.6

  Mauro Codella

### Curlybars 0.4.7 (March 16, 2015)

* Various fixes

  Mauro Codella

### Curlybars 0.4.6 (March 9, 2015)

* Refactors
* `../` in paths

  Mauro Codella

### Curlybars 0.4.5 (March 6, 2015)

* Fixes namespacing problem

  Libo Cannici

### Curlybars 0.4.4 (March 6, 2015)

* Various fixes

  Libo Cannici
  Mauro Codella

### Curlybars 0.4.3 (March 6, 2015)

* Various fixes in validation logic

  Mauro Codella

### Curlybars 0.4.2 (March 5, 2015)

* Relax helper signature constraints

  Mauro Codella

### Curlybars 0.4.1 (March 5, 2015)

* Bugfix: call to helper must tolerate default values in the signature

  Mauro Codella

### Curlybars 0.4.0 (March 5, 2015)

* Introduce validation api

  Mauro Codella

### Curlybars 0.3.0 (March 5, 2015)

* Enforce helpers and block helpers signature

  Mauro Codella

### Curlybars 0.2.1 (March 3, 2015)

* Permit to override default context in block helpers

  Mauro Codella

### Curlybars 0.2.0 (March 1, 2015)

* Improve method whitelisting system

  Libo Cannici

### Curlybars 0.1.9 (February 27, 2015)

* Fixes partial when presenter returns nil

  Mauro Codella

### Curlybars 0.1.8 (February 26, 2015)

* More error messages

  Mauro Codella
  Cristian Planas

### Curlybars 0.1.7 (February 25, 2015)

* Better error messages

  Mauro Codella

### Curlybars 0.1.6 (February 25, 2015)

* Error handling and reporting

  Mauro Codella

### Curlybars 0.1.5 (February 24, 2015)

* Configurable namespace for presenter

  Libo Cannici

### Curlybars 0.1.4 (February 23, 2015)

* Bugfixes

  Mauro Codella

### Curlybars 0.1.3 (February 20, 2015)

* Bugfixes

  Mauro Codella

### Curlybars 0.1.2 (February 20, 2015)

* Bugfixes

  Mauro Codella

### Curlybars 0.1.1 (February 19, 2015)

* Bugfixes

  Mauro Codella

### Curlybars 0.1.0 (February 13, 2015)

* First working stub

  Alphabetic order:
  *Luís Almeida*
  *Libo Cannici*
  *Mauro Codella*
  *Ilkka Oksanen*
  *Cristian Planas*
