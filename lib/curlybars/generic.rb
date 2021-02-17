require 'curlybars/method_whitelist'

module Curlybars
  # A base class that can be used to signify that a helper's return type is a sort a generic.
  #
  # Examples
  #
  #   class GlobalHelperProvider
  #     extend Curlybars::MethodWhitelist
  #
  #     allow_methods slice:     [:helper, [Curlybars::Generic]],
  #                   translate: [:helper, Curlybars::Generic]
  #
  #     def slice(collection, start, length, _)
  #       collection[start, length]
  #     end
  #
  #     def translate(object, locale)
  #       object.translate(locale)
  #     end
  #   end
  #
  #   {{#each (slice articles, 0, 5)}}
  #     Title: {{title}}
  #     Body: {{body}}
  #   {{/each}}
  #
  #   {{#with (translate article "en-us")}}
  #     Title: {{title}}
  #     Body: {{body}}
  #   {{/with}}
  #
  class Generic
    extend Curlybars::MethodWhitelist
  end
end
