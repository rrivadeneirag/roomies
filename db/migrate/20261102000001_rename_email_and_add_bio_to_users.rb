class RenameEmailAndAddBioToUsers < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :email, :email_address
    add_column :users, :bio, :text
  end
end
