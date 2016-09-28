class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :messenger_id
      t.string :name
      t.string :last_command
      t.string :last_question
      t.string :current_card_set_id
      t.string :last_card

      t.timestamps
    end
  end
end
