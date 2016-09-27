class QuizletService

  def self.find_card_set(user, quizlet_id)
    set = CardSet.where(user_id: user.id, quizlet_id: quizlet_id).take
    unless set.present?
      set = CardSet.create(user_id: user.id, quizlet_id: quizlet_id)
      populate_set(set, quizlet_id)
    end
    set
  end

  def self.populate_set(set, quizlet_id)
    set_data = get_card_set(quizlet_id)
    set.title = set_data['title']
    set_data['terms'].each do |card|
      Card.create(card_set_id: set.id, term: card['term'], definition: card['definition'])
    end
  end

  def self.get_card_set(id)
    response = RestClient.get "https://api.quizlet.com/2.0/sets/#{id}?client_id=#{ENV['QUIZLET_CLIENT_ID']}",
                              accept: :json
    JSON.parse(response)
  end

  def self.search_for_set(term)
  end
end