# frozen_string_literal: true

module Layoutable
  extend ActiveSupport::Concern

  included do
    layout 'mailer'

    # email attachements for inline image
    before_action :set_logo_attachment
    def set_logo_attachment
      attachments.inline['logo.png'] = File.read("#{Rails.root}/public/assets/logo.png")
    end

    # for consistent email formatting accross email reader,
    # ensure <p> styles are always style with p style={p_styles}
    helper_method :p_styles, :head_styles
    def p_styles(options = {})
      {
        'font-family' => '-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica Neue, Arial, Noto Sans, sans-serif, Apple Color Emoji, Segoe UI Emoji, Segoe UI Symbol, Noto Color Emoji',
        'font-size' => '15px',
        'font-weight' => 'normal',
        'margin' => '0',
        'margin-bottom' => '15px;'
      }.merge(options)
        .map { |k, v| "#{k}:#{v}" }
        .join(';')
    end

    def head_styles(options = {})
      {
        'font-family' => '-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica Neue, Arial, Noto Sans, sans-serif, Apple Color Emoji, Segoe UI Emoji, Segoe UI Symbol, Noto Color Emoji',
        'font-size' => '24px',
        'font-weight' => 'bold',
        'margin' => '0',
        'margin-bottom' => '15px;'
      }.merge(options)
        .map { |k, v| "#{k}:#{v}" }
        .join(';')
    end
  end
end
