begin
  require 'raven'
rescue LoadError
  raise "Can't find 'sentry-raven' gem. Please add it to your Gemfile or install it."
end

module Resque
  module Failure
    # Failure backend for Sentry (using the raven client gem for Sentry).
    # Similar to the Airbrake backend, this sends exceptions raised in Resque
    # jobs to Sentry. To use, add the following to an initializer:
    #
    #   require 'resque/failure/sentry'
    #
    #   Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Sentry]
    #   Resque::Failure.backend = Resque::Failure::Multiple
    #
    class Sentry < Base
      def save
        event = Raven::Event.capture_exception(exception)
        Raven.send(event) if event
      end

      def self.count
        # We can't get the total # of errors from Sentry so we fake it by
        # asking Resque how many errors it has seen.
        Stat[:failed]
      end
    end
  end
end

