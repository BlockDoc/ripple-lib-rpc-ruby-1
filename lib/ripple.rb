require File.expand_path('../ripple/error', __FILE__)
require File.expand_path('../ripple/configuration', __FILE__)
require File.expand_path('../ripple/api', __FILE__)
require File.expand_path('../ripple/client', __FILE__)
require File.expand_path('../ripple/request', __FILE__)
require File.expand_path('../ripple/response', __FILE__)

module Ripple
  extend Configuration

  # Alias for Ripple::Client.new
  #
  # @return [Ripple::Client]
  def self.client(options={})
    Ripple::Client.new(options)
  end
end