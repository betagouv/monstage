# frozen_string_literal: true

class PagesController < ApplicationController
  layout 'homepage', only: :home

  def reset_cache
    Rails.cache.clear if can?(:reset_cache, current_user)
    redirect_to root_path
  end

  def flyer
    respond_to do |format|
      format.html
      format.pdf do
        send_data(
          File.read(Rails.root.join("public", "MS3_Flyer_2022.pdf")),
          filename: "MS3E_flyer_2022.pdf",
          type: 'application/pdf',
          disposition: 'inline'
        )
      end
    end
  end
end
