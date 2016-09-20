class MessengerService
  COMMAND_TO_METHOD = {
    'select quiz' => :select_quiz,
    'study' => :study,
    'quiz me' => :quiz_me
  }

  def initialize(sender_id, input)
    @user = User.find_or_create_by(messenger_id: sender_id)
    @input = input
  end

  def route_incoming
    return ask_name unless @user.name.present?
    command = @input.downcase.strip
    if COMMAND_TO_METHOD.key?(command)
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
      set_last_question 'give quizlet number'
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
      return set_last_question '1'
    end

    current_card_id = @user.last_question.to_i
    cards = @user.current_card_set.cards

    if current_card_id >= cards.count
      send_message :study_all_done, count: cards.count
      set_last_question '1'
    else
      card = cards.where(id: current_card_id).take
      set_last_question (current_card_id + 1).to_s
      send_message :study_flash_card, term: card.term, definition: card.definition
    end
  end

  def quiz_me
    send_message :quiz_me_text
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

  def set_last_question(question)
    @user.update_attribute(:last_question, question)
  end
end