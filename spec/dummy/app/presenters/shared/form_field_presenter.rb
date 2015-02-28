class Shared::FormFieldPresenter
  extend Curlybars::MethodWhitelist
  attr_accessor :label, :value

  allow_methods :label, :value, :name, :id

  def initialize(params)
    @resource_name = params[:resource_name]
    @name = params[:name]
    @label = params[:label]
    @value = params[:value]
  end

  def name
    "#{@resource_name}[#{@name}]"
  end

  def id
    "#{@resource_name}_#{@name}"
  end
end
