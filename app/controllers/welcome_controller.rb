class WelcomeController < ApplicationController
  before_filter :set_up_amqp, :set_up_pusher

  def index
  end

  protected

  def set_up_amqp
    u = ENV['CLOUDAMQP_URL']
    b = Bunny.new(u.blank? ? nil : u)
    b.start # Does not return b.
    @bunny_queue = b.queue 'test1'
    b.exchange('').publish 'Hello from set_up_amqp', :key => 'test1'
  end

  def set_up_pusher
    Pusher['test_channel'].trigger 'greet', :greeting => 'Hello from set_up_pusher'
  end

end
