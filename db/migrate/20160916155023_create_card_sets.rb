class CreateCardSets < ActiveRecord::Migration[5.0]
  def change
    create_table :card_sets do |t|
      t.integer :quizlet_id
      t.string :title
      t.string :created_by

      t.timestamps
    end
  end
end
