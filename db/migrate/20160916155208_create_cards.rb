class CreateCards < ActiveRecord::Migration[5.0]
  def change
    create_table :cards do |t|
      t.integer :quizlet_id
      t.string :term
      t.string :definition
      t.integer :card_set_id

      t.timestamps
    end
  end
end
