class Dashboards::NewPresenter < Curlybars::Presenter
  presents :name

  def form(&)
    form_for(:dashboard, &)
  end

  class FormPresenter < Curlybars::Presenter
    presents :form, :name

    def name_field(&)
      content_tag :div, class: "field" do
        yield
      end
    end

    class NameFieldPresenter < Curlybars::Presenter
      presents :form, :name

      def label
        "Name"
      end

      def input
        @form.text_field :name, value: @name
      end
    end
  end
end
