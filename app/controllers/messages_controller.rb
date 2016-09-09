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
    puts request.body
    head :ok
  end
end