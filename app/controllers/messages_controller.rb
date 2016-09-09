class MessagesController < ApplicationController
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
      params['message']['entry'].each do |messaging|
        messaging.each do |message|
          puts "\n\n ------> FIND ME IN THE LOG FILE --------------\n\n"
          puts message[0]['sender']['id']
          puts "\n\n ------> FIND ME IN THE LOG FILE --------------\n\n"
        end
      end
    end
    head :ok
  end
end