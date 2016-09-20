class CreateCards < ActiveRecord::Migration[5.0]
  def change
    create_table :cards do |t|
      t.integer :card_set_id
      t.string :term
      t.string :definition
      t.integer :times_correct, default: 0
      t.integer :times_tested, default: 0

      t.timestamps
    end
  end
end
