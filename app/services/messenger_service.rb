class MessengerService

  def initialize(sender_id, input)
    @user = User.find_or_create_by(messenger_id: sender_id)
    @input = input
  end

  def route_incoming
    return ask_name unless @user.name.present?
    @input = @input.downcase.strip
    case @input
      when 'register'
        @user.update_attribute(:last_command, 'register')
        return select_quiz
      when 'quiz me'
        @user.update_attribute(:last_command, 'quiz me')
        return quiz_me
      when 'study'
        @user.update_attribute(:last_command, 'study')
        return study
      else
        case @user.last_command
          when 'register'
            @user.update_attribute(:last_command, 'register')
            return select_quiz
          when 'quiz me'
            @user.update_attribute(:last_command, 'quiz me')
            return quiz_me
          when 'study'
            @user.update_attribute(:last_command, 'study')
            return study
          else
            return send_message "Sorry I don't understand that. Type 'register', 'quiz me', or 'study'"
        end
    end
  end

  private

  def ask_name
    @user.update_attribute(:last_command, 'ask name')
    if @user.last_question.nil?
      @user.update_attribute(:last_question, 'ask name')
      send_message "What's your name, or what would you like me to call you? :)"
      sleep 0.5
      send_message "I think that would be more polite than automatically getting it from your facebook account :P"
    else
      @user.update_attribute(:name, @input)
      send_message "Nice to meet you #{@user.name}! :D"
      send_message "Type 'register', 'study', or 'quiz me'"
      clear_state
    end
  end

  def select_quiz
    send_message "You chose select quiz"
    clear_state
  end

  def quiz_me
    send_message "You quiz me"
    clear_state
  end

  def study
    send_message "You study"
    clear_state
  end

  def send_message(message)
    data = {
        recipient: {id: @user.messenger_id},
        message: {text: message}
    }.to_json
    RestClient.post "https://graph.facebook.com/v2.6/me/messages?access_token=#{ENV['PAGE_ACCESS_TOKEN']}",
                    data, content_type: :json
  end

  def clear_state
    @user.update_attribute(:last_command, nil)
    @user.update_attribute(:last_question, nil)
  end

end