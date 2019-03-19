class Rg2aFormBuilder < ActionView::Helpers::FormBuilder
  def rg2a_explain_required_asterisk
    "<p>Les champs avec <span class='text-danger'>*</span> sont obligatoires</p>".html_safe
  end

  def rg2a_required_content_tag
    @template.content_tag(:abbr, '*', title: '(obligatoire)',
                                      aria: { hidden: "true" })
  end
end
