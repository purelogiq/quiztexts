class User < ApplicationRecord
  has_many :card_sets

  def current_card_set
    CardSet.where(id: current_card_set_id)
  end
end
