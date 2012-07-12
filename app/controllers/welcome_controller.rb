class WelcomeController < ApplicationController
  before_filter :set_up_amqp, :set_up_memcachier

  def index
  end

  protected

  def set_up_amqp
    u = ENV['CLOUDAMQP_URL']
#    b = Bunny.new(u.blank? ? nil : u)
    b = Bunny.new
    b.start # Does not return b.
    @bunny_queue = b.queue 'test1'
    b.exchange('').publish 'Hello from set_up_amqp in Rails app', :key => 'test1'
  end

  def set_up_memcachier
#    Rails.cache.write 'foo', 'Hello from set_up_memcachier in Rails app'
  end

end
