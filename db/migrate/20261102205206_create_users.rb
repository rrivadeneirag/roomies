class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    # The users table already exists (created in Assignment 2).
    # The authentication generator added this migration automatically; it is a
    # no-op because we reuse the existing users table (with email_address + password_digest).
  end
end
