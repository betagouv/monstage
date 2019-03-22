class Rg2aFormBuilder < ActionView::Helpers::FormBuilder
  def rg2a_explain_required_asterisk
    "<p class='small text-muted' aria-hidden='true'>Les champs avec <abbr class='text-danger' title='(obligatoire)'>*</abbr> sont obligatoires.</p>".html_safe
  end

  def rg2a_required_content_tag
    @template.content_tag(:abbr, '*', title: '(obligatoire)',
                                      aria: { hidden: "true" })
  end
end
