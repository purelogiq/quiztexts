class MessagesController < ApplicationController
  MESSAGES = [
      'Hi! How are you!',
      'I\'m hungry, have anything to eat?',
      'K',
      'Hello world'
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
        user = entry['messaging'][0]['sender']['id']
        message_data = {
            recipient: {id: user},
            message: {text: MESSAGES.sample}
        }.to_json
        send_message(message_data)
      end
    end
    head :ok
  end

  private

  def send_message(data)
    RestClient.post "https://graph.facebook.com/v2.6/me/messages?access_token=#{ENV['PAGE_ACCESS_TOKEN']}",
                    data, :content_type => :json
  end
end