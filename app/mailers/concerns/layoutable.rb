# frozen_string_literal: true

module Layoutable
  extend ActiveSupport::Concern

  included do
    layout 'dsfr_mailer'

    # email attachements for inline image
    before_action :set_logo_attachment
    def set_logo_attachment
      attachments.inline['logo.png'] = File.read("#{Rails.root}/public/assets/logo.png")
      attachments.inline['logo-mon-stage-3e-bleu-short.svg'] = File.read("#{Rails.root}/public/assets/logo-mon-stage-3e-bleu-short.svg")
      attachments.inline['tweeter.png'] = File.read("#{Rails.root}/public/assets/tweeter.png")
      attachments.inline['insta.png'] = File.read("#{Rails.root}/public/assets/insta.png")
      attachments.inline['linked_in.png'] = File.read("#{Rails.root}/public/assets/linked_in.png")
      attachments.inline['rf.png'] = File.read("#{Rails.root}/public/assets/rf.png")
    end

    # for consistent email formatting accross email reader,
    # ensure <p> styles are always style with p style={p_styles}
    helper_method :p_styles,
                  :p_styles_italic,
                  :head_styles,
                  :span_bold,
                  :p_cyclop_styles,
                  :head_cyclop_styles,
                  :hint_styles,
                  :tr_air_style

    def font_family
      '-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica Neue, Arial, Noto Sans, sans-serif, Apple Color Emoji, Segoe UI Emoji, Segoe UI Symbol, Noto Color Emoji'
    end

    def head_styles(options = {})
      hash = {
        'font-family' => font_family,
        'font-size' => '24px',
        'font-weight' => 'bold',
        'margin' => '0',
        'margin-bottom' => '15px;'
      }
      joiner(hash, options)
    end

    def p_styles(options = {})
      hash = {
        'font-family' => font_family,
        'font-size' => '15px',
        'font-weight' => 'normal',
        'margin' => '0',
        'margin-bottom' => '15px;'
      }
      joiner(hash, options)
    end

    def p_styles_italic(options = {})
      {
        'font-family' => font_family,
        'font-size' => '15px',
        'font-weight' => 'normal',
        'font-style' => 'italic ',
        'padding-left' => '25px',
        'margin' => '0',
        'margin-bottom' => '15px;'

      }.merge(options)
        .map { |k, v| "#{k}:#{v}" }
        .join(';')
    end

    def hint_styles(options = {})
      {
        'font-family' => '-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica Neue, Arial, Noto Sans, sans-serif, Apple Color Emoji, Segoe UI Emoji, Segoe UI Symbol, Noto Color Emoji',
        'font-size' => '11px',
        'font-weight' => 'lighter',
        'margin' => '0',
        'margin-bottom' => '15px;'
      }.merge(options)
        .map { |k, v| "#{k}:#{v}" }
        .join(';')
    end

    def span_bold(options = {})
      hash = {
        'font-family' => font_family,
        'font-size' => '15px',
        'font-weight' => 'bolder'
      }
      joiner(hash, options)
    end

    def p_cyclop_styles(options={})
      hash = {
        'font-family' => font_family,
        'font-size' => '17px',
        'font-weight' => '400',
        'line-height'=> '20px',
        'letter-spacing' => '0em',
        'text-align' => 'left',
        'margin' => '0',
        'margin-bottom' => '15px;'
      }
      joiner(hash, options)
    end

    def head_cyclop_styles(options = {})
      hash = {
        'font-family' => font_family,
        'font-size' => '28px',
        'font-weight' => 'bold',
        'margin' => '0',
        'color' => '#000091',
        'margin-bottom' => '15px;'
      }
      joiner(hash, options)
    end

    def tr_air_style(options = {})
      hash = {
        'font-family' => font_family,
        'font-size' => '15px',
        'font-weight' => 'normal',
        'margin' => '0',
        'line-height' => '30px;',
       'vertical-align' => 'bottom;'
      }
      joiner(hash, options)
    end

    def joiner(hash, options)
      hash.merge(options)
          .map { |k, v| "#{k}:#{v}" }
          .join(";")
    end
  end
end
