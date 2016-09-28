class MessengerService
  COMMAND_TO_METHOD = {
    'select quiz' => :select_quiz,
    'study' => :study,
    'quiz me' => :quiz_me,
    'help' => :help
  }

  QUIZ_ME_CORRECT_MESSAGES = [:quiz_me_correct_1, 
                              :quiz_me_correct_2, 
                              :quiz_me_correct_3]

  QUIZ_ME_INCORRECT_MESSAGES = [:quiz_me_incorrect_1, 
                                :quiz_me_incorrect_2, 
                                :quiz_me_incorrect_3]

  def initialize(sender_id, input)
    @user = User.find_or_create_by(messenger_id: sender_id)
    @input = input
  end

  def route_incoming
    return ask_name unless @user.name.present?
    command = @input.downcase.strip
    if COMMAND_TO_METHOD.key?(command)
      clear_state
      @user.update_attribute(:last_command, command)
      self.send(COMMAND_TO_METHOD[command])
    elsif @user.last_command
      self.send(COMMAND_TO_METHOD[@user.last_command])
    else
      unknown_command
    end
  end

  private

  def ask_name
    @user.update_attribute(:last_command, 'ask name')
    if @user.last_question.nil?
      @user.update_attribute(:last_question, 'ask name')
      send_message :ask_name_question
      send_message :ask_name_confirmation
    else
      @user.update_attribute(:name, @input)
      send_message :ask_name_nice_to_meet, name: @input
      send_message :ask_name_getting_started
      clear_state
    end
  end

  def select_quiz
    if @user.last_question == 'give quizlet number'
      card_set = QuizletService.find_card_set(@user, @input) # TODO handle failure case
      @user.current_card_set_id = card_set.id
      @user.save
      send_message :select_quiz_success, title: card_set.title
      clear_state
    else
      save_last_question 'give quizlet number'
      send_message :select_quiz_give_me_quizlet_number
    end
  end

  def study
    unless @user.current_card_set
      clear_state
      return send_message :study_choose_set_first
    end

    unless @user.last_question
      send_message :study_getting_started
      return save_last_question '0'
    end

    min_times_studied = Card.all.to_a.map{|x| x.times_studied}.min
    card = Card.where(times_studied: min_times_studied).to_a.sample

    card.update_attribute(:times_studied, card.times_studied + 1)
    send_message :study_flash_card, term: card.term, definition: card.definition
  end

  def quiz_me

    unless @user.current_card_set
      clear_state
      return send_message :study_choose_set_first
    end

    unless @user.last_question
      send_message :quiz_me_getting_started
      return save_last_question '__start__'
    end

    min_times_correct = Card.all.to_a.map{|x| x.times_correct}.min
    card = Card.where("times_correct < ?", 3).where(times_correct: min_times_correct).to_a.sample


    if @user.last_question == '__start__'
      save_last_question card.id
      return send_message :quiz_me_term, term: card.term
    end

    last_card = Card.find(@user.last_question)

    if card.nil?
      quiz_me_check_correctness(last_card, '')
      send_message :quiz_me_all_done, count: cards.count
      save_last_question '__start__'
    else
      quiz_me_check_correctness(last_card, 'On to the next one!')
      next_card = card
      @user.update_attribute(:last_question, next_card.id)
      save_last_question(card.id)
      send_message :quiz_me_term, term: next_card.term
    end
  end

  def help
    send_message :help
    clear_state
  end

  def unknown_command
    send_message :unknown_command
    clear_state
  end

  def send_message(message, data_hash={})
    data = {
        recipient: {id: @user.messenger_id},
        message: {text: I18n.t(message, data_hash)}
    }.to_json
    RestClient.post "https://graph.facebook.com/v2.6/me/messages?access_token=#{ENV['PAGE_ACCESS_TOKEN']}",
                    data, content_type: :json
    sleep 0.7 # In the future use an async task runner.
  end

  def clear_state
    @user.update_attribute(:last_command, nil)
    @user.update_attribute(:last_question, nil)
  end

  def save_last_question(question)
    @user.update_attribute(:last_question, question)
  end

  def quiz_me_check_correctness(card, comment)
    if card.definition.downcase.strip == @input.downcase.strip
      send_message QUIZ_ME_CORRECT_MESSAGES.sample, comment: comment
      card.update_attribute(:times_correct, card.times_correct + 1)
    else
      send_message QUIZ_ME_INCORRECT_MESSAGES.sample, definition: card.definition, comment: comment
    end
  end
end