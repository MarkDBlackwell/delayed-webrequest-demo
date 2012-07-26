class WelcomeController < ApplicationController
  before_filter :set_up_amqp,   :except => :ajax
  after_filter :tear_down_amqp, :except => :ajax

  respond_to :html, :json

# Following stackoverflow.com/questions/7548531/how-do-i-reload-a-div-with-a-rails-partial

  def index
    external_request_urls = %w[ 
        http://whoismyrepresentative.com/whoismyrep.php?zip=46544
        http://whoismyrepresentative.com/whoismyrep.php?zip=10001 ]

#   external_request_urls.each {|e| @exchange.publish e}
#   @exchange.publish 'Hello from Rails app (AMQP)', :mandatory => true
## print '@exchange: ';p @exchange
    @exchange.publish 'Hello from Rails app (AMQP)', :key => routing_key

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
    # 'amqp://guest:guest@disk30:5672'
    ENV['CLOUDAMQP_URL']
  end

  def begin_amqp_session(b)
#   b.start_session # Does not return b.
    b.start # Does not return b.

    raise unless :connected == b.status
## print 'b.status: '; p b.status
  end

  def binding_key
    # 'delayed-webrequest'
    ''
  end

  def close_amqp_connection(b)
    r = b.status
## print 'r: '; p r
    raise unless :connected == r
    r = b.stop
## print 'r: '; p r
    raise unless :not_connected == r
    r = b.stop
## print 'r: '; p r
## print 'b: '; p b
    raise unless r.nil?
  end

  def create_or_access_queue(b)
#   q = b.queue queue_name,
#       :binding_key => binding_key
    q = b.queue queue_name
    raise 'q is nil' if q.nil?
    q
  end

  def end_amqp_session(b)
    # Bunny doesn't break this out.
  end

  def exchange_name
    # 'com.herokuapp.delayed-webrequest.exchange'
    default_exchange_name = '' # Binds to all queues.
  end

  def open_amqp_connection
    u = amqp_url
    raise 'u is nil' if u.nil?
    o = { \
 #         :logfile => 'log/bunny.log', # Not on Heroku.
 #         :logging => true
        }
    b = ('' == u) ? (Bunny.new o) : (Bunny.new u, o)
    raise unless :not_connected == b.status
## print 'b.status: '; p b.status
    b
  end

  def pop_message(q)
    q.pop[:payload].to_s
  end

  def queue_name
    # 'com.herokuapp.delayed-webrequest.queue'
    # ''
    'test1'
  end

  def routing_key
    # 'delayed-webrequest'
    # ''
    'test1'
  end

  def set_up_amqp
    b = open_amqp_connection
    begin_amqp_session b
#    raise unless :qos_ok == b.qos {}
    q = create_or_access_queue b
    e = use_exchange b
    @bunny, @exchange = b, e
    true
  end

  def tear_down_amqp
    end_amqp_session @bunny
    close_amqp_connection @bunny
    true
  end

  def use_exchange(b)
    o = { \
        :type => :direct
#        :type => :direct,
#        :key => routing_key,
#        :mandatory => true
        }
#   e = b.exchange exchange_name, o
    b.exchange exchange_name
  end

end
