class AddKeyPhraseToUsers < ActiveRecord::Migration
  def change
    add_column :users, :key_phrase, :text
  end
end
