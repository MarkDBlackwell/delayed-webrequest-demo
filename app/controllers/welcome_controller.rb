class WelcomeController < ApplicationController
  before_filter :set_up_amqp,   :except => :ajax
  after_filter :tear_down_amqp, :except => :ajax

  respond_to :html, :json

# Following stackoverflow.com/questions/7548531/how-do-i-reload-a-div-with-a-rails-partial

AMQP_URL      = ENV['CLOUDAMQP_URL']
EXCHANGE_NAME = 'com.herokuapp.delayed-webrequest.exchange'
ROUTING_KEY   = 'delayed-webrequest'

  def index
    external_request_urls = %w[ 
        http://whoismyrepresentative.com/whoismyrep.php?zip=46544
        http://whoismyrepresentative.com/whoismyrep.php?zip=10001 ]

#   external_request_urls.each {|e| @exchange.publish e}
#   @exchange.publish 'Hello from Rails app (AMQP)', :mandatory => true
    @exchange.publish 'Hello from Rails app (AMQP)'

    @cached_foo = Rails.cache.read 'foo'
    Rails.cache.clear 'foo'
    @events = []
  end

  def ajax
    @events = []
    @events = { "message" => "Content from Rails app" }

    respond_to do |format|
      format.json do
        render :json => @events
      end
      format.html do
        render :text => '{ "a" : "b" }'
      end
    end
  end

  protected

  def amqp_url
    # ENV['CLOUDAMQP_URL']
    'amqp://guest:guest@disk30:5672'
  end

  def binding_key
    # 'delayed-webrequest'
    ''
  end

  def close_amqp(b)
    b.stop
  end

  def create_or_access_queue(b)
    q = b.queue queue_name,
        :binding_key => binding_key
    raise 'q is nil' if q.nil?
    q
  end

  def exchange_name
    # 'com.herokuapp.delayed-webrequest.exchange'
    default_exchange_name = '' # Binds to all queues.
  end

  def pop_message(q)
    q.pop[:payload].to_s
  end

  def queue_name
    # 'com.herokuapp.delayed-webrequest.queue'
    # 'test1'
    ''
  end

  def set_up_amqp
    b = start_amqp_connection
    q = create_or_access_queue b
    e = use_exchange b
    [b, q]
  end

  def set_up_amqp
#   u = AMQP_URL
    u = 'amqp://guest@disk30:5672'
    raise 'u is nil' if u.nil?
#   @bunny = u.blank? ? (Bunny.new :logging => false) : (Bunny.new u, :logging => false)
#   @bunny = u.blank? ? Bunny.new : (Bunny.new u)
#   @bunny = Bunny.new u,
#   @bunny.logging = false
#   @bunny = u.blank? ? Bunny.new : (Bunny.new u)
#   @bunny.logfile = 'log/bunny.log' # Not on Heroku.
#   @bunny.logging = true
    @bunny = if u.blank?
      Bunny.new \
          :logfile => 'log/bunny.log', # Not on Heroku.
          :logging => true
    else
#   raise 'here'
     Bunny.new u, \
#    Bunny.new u
         :logfile => 'log/bunny.log', # Not on Heroku.
#        :logging => false
         :logging => true
    end
# p @bunny
    s = @bunny.start # Returns nil. 
# Start a connection to AMQP:
#   raise "Bunny not connected: #{s}" unless :connected == (s = @bunny.start)
p s
#    sleep 10000
#   en = EXCHANGE_NAME
    en = ''
#   rk = ROUTING_KEY
    rk = ''
    @exchange = @bunny.exchange en,
#        :type => :direct,
        :type => :direct
#        :key => rk,
#        :mandatory => true

#   @exchange = @bunny.exchange EXCHANGE_NAME
#   @exchange.type = :direct
#   @exchange = @bunny.exchange EXCHANGE_NAME,
#       :type => :direct
#   @exchange.key  = ROUTING_KEY
#   @exchange.mandatory = true
  end

  def start_amqp_connection
    u = amqp_url
    raise 'u is nil' if u.nil?
    o = { \
          :logfile => 'log/bunny.log', # Not on Heroku.
          :logging => true
        }
    b = ('' == u) ? (Bunny.new o) : (Bunny.new u, o)
    b.start # Does not return b. 
    b
  end

  def tear_down_amqp
    @bunny.stop # Close the connection to AMQP.
  end

  def use_exchange(b)
    e = b.exchange exchange_name
  end

end
