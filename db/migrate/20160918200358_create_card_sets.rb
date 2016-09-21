class CreateCardSets < ActiveRecord::Migration[5.0]
  def change
    create_table :card_sets do |t|
      t.integer :user_id
      t.string :quizlet_id
      t.string :title

      t.timestamps
    end
  end
end
