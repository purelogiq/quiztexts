class MessagesController < ApplicationController
  MESSAGES = [
      'Hi! How are you!',
      'I\'m hungry, have anything to eat?',
      'My name is Flashy',
      'What do you want to study today? :)',
      'When is your big test!?'
  ]

  def webhook
    if params['hub.mode'] == 'subscribe' &&
         params['hub.verify_token'] == 'flashy_is_the_bomb'
      render text: params['hub.challenge']
    else
      head :forbidden
    end
  end

  def incoming
    if params['object'] == 'page'
      params['entry'].each do |entry|
        if entry['messaging'][0]['message'] # TODO account for multiple messages
          user = entry['messaging'][0]['sender']['id']
          text = entry['messaging'][0]['message']['text']
          Rails.logger.info text
          send_message(user, MESSAGES.sample)
        end
      end
    end
    head :ok
  end

  private

  def send_message(user, message)
    data = {
        recipient: {id: user},
        message: {text: message}
    }.to_json
    RestClient.post "https://graph.facebook.com/v2.6/me/messages?access_token=#{ENV['PAGE_ACCESS_TOKEN']}",
                    data, content_type: :json
  end
end