class WelcomeController < ApplicationController
  def show
    @curlybars_global_helpers = [GlobalHelpers.new(view_context)]
  end
end
