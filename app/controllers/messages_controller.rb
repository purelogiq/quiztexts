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
         params['hub.verify_token'] == 'flashy_is_the_bomb' # Sorta unsafe
      render text: params['hub.challenge']
    else
      head :forbidden
    end
  end

  def incoming
    if params['object'] == 'page'
      params['entry'].each do |entry|
        if entry['messaging'][0]['message'] # TODO account for multiple messages
          sender_id = entry['messaging'][0]['sender']['id']
          text = entry['messaging'][0]['message']['text']
          messenger_service = MessengerService.new(sender_id, text)
          messenger_service.route_incoming
        end
      end
    end
    head :ok
  end
end