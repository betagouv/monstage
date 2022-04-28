class NewsletterController < ApplicationController

  def subscribe
    redirect_to root_path,
                flash: { warning: "Votre email a l'air erroné" } and return unless newsletter_email_checked?

    user = User.new(email: email_param[:newsletter_email])
    result = Services::SyncEmailCampaigns.new.add_contact(user: user)
    redirect_to root_path,
                notice: "Votre email a bien été enregistré" and return if success?(result)

    duplicate_message = 'Votre email était déjà enregistré. :-) .'
    redirect_to root_path,
                flash: { warning: duplicate_message } and return if result == :previously_existing_email

    err_message = "Une erreur s'est produite et nous n'avons pas " \
                  "pu enregistrer votre email"
    redirect_to root_path, flash: { warning: err_message }
  end

  private

  def email_param
    params.permit(:newsletter_email)
  end

  def success?(result)
    result.is_a?(Array) && result.size >= 4 && result[3] == email_param[:newsletter_email]
  end

  def newsletter_email_checked?
    email_param[:newsletter_email].match?(/[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+/)
  end
end
