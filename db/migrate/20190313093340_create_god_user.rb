class CreateGodUser < ActiveRecord::Migration[5.2]
  def up
    God.create!(password: Credentials.enc(:god, :password, prefix_env: false),
                email: Credentials.enc(:god, :email, prefix_env: false),
                confirmed_at: Time.now.utc,
                first_name: 'Super',
                last_name: 'Admin')
  end

  def down
    God.destroy_all
  end
end
