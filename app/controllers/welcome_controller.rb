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

  def routing_key
    # 'delayed-webrequest'
    ''
  end

  def set_up_amqp
    b = start_amqp_connection
    q = create_or_access_queue b
    e = use_exchange b
    @bunny = b
    @exchange = e
    true
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
    true
  end

  def use_exchange(b)
    o = { \
        :type => :direct,
        :key => routing_key,
        :mandatory => true
        }
    e = b.exchange exchange_name, o
  end

end
