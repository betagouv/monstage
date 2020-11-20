# frozen_string_literal: true

class Rg2aFormBuilder < ActionView::Helpers::FormBuilder
  def rg2a_explain_required_asterisk(p_class_name: "")
    @template.content_tag(:p, class: "small text-muted #{p_class_name}", aria: {hidden: true}) do
      @template.concat("Les champs avec ")
      @template.concat(rg2a_required_content_tag(class_names: "text-danger"))
      @template.concat(" sont obligatoires")
    end
  end

  def rg2a_required_content_tag(class_names: "")
    @template.content_tag(:abbr, '*', title: '(obligatoire)',
                                      class: class_names,
                                      aria: { hidden: 'true' })
  end
end
