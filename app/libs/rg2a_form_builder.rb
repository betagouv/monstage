class Rg2aFormBuilder < ActionView::Helpers::FormBuilder
  def label(method, text = nil, options = {}, &block)
    if options.key?(:required)
      text = @template.content_tag :span do
        text.concat(@template.content_tag(:abbr, '*', title: '(obligatoire)', aria: { hidden: "true" })).html_safe
      end
      options.delete(:required)
    end
    super
  end
end
