class User < ApplicationRecord
  has_many :card_sets

  def current_card_set
    CardSet.find(current_card_set_id)
  end
end
