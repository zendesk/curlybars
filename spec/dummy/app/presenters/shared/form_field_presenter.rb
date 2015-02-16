class Shared::FormFieldPresenter
  attr_accessor :label, :value

  def initialize(params)
    @resource_name = params[:resource_name]
    @name = params[:name]
    @label = params[:label]
    @value = params[:value]
  end

  def name
    "#{@resource_name}[#{@name}]"
  end
end
