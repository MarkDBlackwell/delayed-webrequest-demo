class WelcomeController < ApplicationController
  before_filter :set_up_amqp

  respond_to :html, :js

# Following stackoverflow.com/questions/7548531/how-do-i-reload-a-div-with-a-rails-partial

  def index
    @cached_foo = Rails.cache.read 'foo'
    Rails.cache.clear 'foo'
    @events = []
  end

  def ajax_load_events
    @events << 'abc'

    respond_to do |format|
      format.js
    end
  end

  protected

  def set_up_amqp
    u = ENV['CLOUDAMQP_URL']
    raise 'u is nil' if u.nil?
    my_queue_name = 'test1'
    default_exchange_name = '' # Binds to all queues.
    my_exchange_name = default_exchange_name

##  b = Bunny.new(u.blank? ? nil : u)
    b = Bunny.new u
    b.start # Does not return b. Start a connection to AMQP.

    q = b.queue my_queue_name # Create or access the queue.
    raise 'q is nil' if q.nil?

    e = b.exchange my_exchange_name # Use a direct exchange.
    e.publish 'Hello from Rails app (AMQP)', :key => my_queue_name
    b.stop # Close the connection to AMQP.
  end

end
