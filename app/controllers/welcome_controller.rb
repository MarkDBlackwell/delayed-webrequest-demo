class WelcomeController < ApplicationController
  def index
    Pusher['test_channel'].trigger('greet', {
      :greeting => "Hello there!"
    })

  end
end
