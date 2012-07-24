class WelcomeController < ApplicationController
  before_filter :set_up_amqp
  after_filter :tear_down_amqp

  respond_to :html, :json

# Following stackoverflow.com/questions/7548531/how-do-i-reload-a-div-with-a-rails-partial

AMQP_URL      = ENV['CLOUDAMQP_URL']
EXCHANGE_NAME = 'com.herokuapp.delayed-webrequest'

  def index
    external_request_urls = %w[ 
        http://whoismyrepresentative.com/whoismyrep.php?zip=46544
        http://whoismyrepresentative.com/whoismyrep.php?zip=10001 ]

##  exchange.publish 'Hello from Rails app (AMQP)'
    external_request_urls.each {|e| @exchange.publish e}

    @cached_foo = Rails.cache.read 'foo'
    Rails.cache.clear 'foo'
    @events = []
  end

  def ajax_load_events
    raise 'got'
    @events = []
    @events << 'abc'

    respond_to do |format|
      format.json do
        render :json => @events
      end
      format.html do
        render :text => 'Should request JSON format'
      end
    end
  end

  protected

  def set_up_amqp
    u = AMQP_URL
    raise 'u is nil' if u.nil?
    @bunny = u.blank? ? (Bunny.new :logging => false) : (Bunny.new u, :logging => false)
    @bunny.start # Returns nil. Start a connection to AMQP.
    @exchange = @bunny.exchange EXCHANGE_NAME, :type => :direct
  end

  def tear_down_amqp
    @bunny.stop # Close the connection to AMQP.
  end

end
