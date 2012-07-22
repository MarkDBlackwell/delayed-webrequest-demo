class WelcomeController < ApplicationController
  before_filter :set_up_amqp

  respond_to :html, :js

# Following stackoverflow.com/questions/7548531/how-do-i-reload-a-div-with-a-rails-partial

AMQP_URL_ENVIRONMENT_VARIABLE = 'CLOUDAMQP_URL'
EXCHANGE_NAME = 'com.herokuapp.delayed-webrequest'

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
    u = ENV[AMQP_URL_ENVIRONMENT_VARIABLE]
    raise 'u is nil' if u.nil?
    bunny = u.blank? ? (Bunny.new :logging => false) : (Bunny.new u, :logging => false)
    bunny.start # Returns nil. Start a connection to AMQP.

    exchange = bunny.exchange EXCHANGE_NAME, :type => :direct

    external_request_url = 'http://whoismyrepresentative.com/whoismyrep.php?zip=46544'
##  exchange.publish 'Hello from Rails app (AMQP)'
    exchange.publish external_request_url

    bunny.stop # Close the connection to AMQP.
  end

end
