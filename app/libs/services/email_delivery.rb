# Since documentation is missing note these two work
# response = sendgrid_client.marketing.contacts.get # ok
# response = sendgrid_client.marketing.lists.get # ok
# see https://github.com/sendgrid/sendgrid-ruby/issues/391#issuecomment-583059532

module Services
  class EmailDelivery
    # require 'sendgrid-ruby'

    # https://github.com/sendgrid/sendgrid-nodejs/issues/953#issuecomment-511227621
    # {"0":{"id":"e2_T","name":"role","field_type":"Text","_metadata":{"self":"https://api.sendgrid.com/v3/marketing/field_definitions/e2_T"}}}
    # {"1":{"id":"e3_T","name":"monstage_id","field_type":"Text","_metadata":{"self":"https://api.sendgrid.com/v3/marketing/field_definitions/e3_T"}}}
    SENDGRID_CUSTOM_FIELD_IDS = {
      role:  "e2_T",
      monstage_id: "e3_T"
    }

    def initialize(user = nil)
      api_key = Rails.application.credentials[:sendgrid][:api_key]

      @sendgrid_client = SendGrid::API.new(api_key: api_key).client
      @user = user
    end

    def add_contact
      return if @user.nil?

      payload = {
        request_body: {
          contacts: [user_data(@user)]
        }
      }

      response = @sendgrid_client.marketing
                                 .contacts
                                 .put(payload)
                                 # OK réponse en 202
      # TODO : error handling
      # self.parse_result(response.body) #ok
    end

    def contact_delete(email:)
      return if @user.nil?

      sendgrid_user_email_id = sendgrid_email_id(email: email)
      if sendgrid_user_email_id
        payload = {query_params: { ids: sendgrid_user_email_id }}
        response = @sendgrid_client.marketing
                                   .contacts
                                   .delete( payload)

        raise unless ok_status(response.status_code)
        # TODO : error handling
      else
        puts 'sendgrid_user_email_id is nil'
      end
    end

    def contact_list
      response = @sendgrid_client.marketing.contacts.get
      parse_result(body: response.body)
    end

    # Temporaire

    def add_etienne
      params = {
        contacts: [
          {
            email: 'weil.etienne@hotmail.fr',
            first_name: 'Etienne',
            last_name: 'WEIL',
            "custom_fields": {
              "e3_T": '42',
              "e2_T": 'dev'
            }
          }
        ]
      }
      response = @sendgrid_client.marketing
                                 .contacts
                                 .put(request_body: params) # OK réponse en 202
      response.status_code
    end

    # def self.user_fields
    #   targeted_fields = %i[email id role first_name last_name]

    #   users_hash = {}
    #   TARGETED_USER_TYPES.each do |category|
    #     users_hash[category.to_sym] = class_eval("Users::#{category}").all
    #                                                                   .pluck(*targeted_fields)
    #   end
    #   users_hash
    # end
    # Temporaire fin

    private

    def user_data(user:)
      {
        "email": user.email,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "custom_fields": custom_fields(user: user)
      }
    end

    def custom_fields(user:)
      custom_fields = {}
      custom_fields[SENDGRID_CUSTOM_FIELD_IDS[:monstage_id]] = user.id
      custom_fields[SENDGRID_CUSTOM_FIELD_IDS[:role]] = user.role
      custom_fields
    end

    def sendgrid_email_id(email:)
      # params = { contact: { email: email} }
      params = { contact: { email: 'weil.etienne@hotmail.fr' } }
      response = @sendgrid_client.marketing.contacts.get(request_body: params)
      user_result = parse_result(body: response.body)
      user_result.empty? ? nil : user_result.first[:id]
    end

    def parse_result(body:)
      hash_response = JSON.parse body
      result = hash_response['result']
      result.map(&:symbolize_keys)
    end

    def ok_status(status)
      status = status.to_i
      [199, status, 227].sort.second == status
    end
  end
end
