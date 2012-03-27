module Fluent
  class ApnsOutput < BufferedOutput
    Fluent::Plugin.register_output('apns', self)
    attr_reader :host, :port, :pem, :password

    def initialize
      super

      require 'apnserver'
    end

    def configure(conf)
      super

      @host     = conf.fetch('host')     { 'gateway.sandbox.push.apple.com' }
      @port     = conf.fetch('port')     { 2195 }.to_i
      @pem      = conf.fetch('pem')      { raise Fluent::ConfigError, "pem is a required attribute" }
      @password = conf.fetch('password') { nil }

      @apns = ApnServer::Client.new(@pem, @host, @port, @password)
    end

    def start
      super

      @apns.connect!
    end

    def shutdown
      super

      @apns.disconnect!
    end

    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end

    def write(chunk)
      chunk.msgpack_each do |(tag, time, record)|
        notification = ApnServer::Notification.new
        notification.device_token = record['device_token']
        notification.alert        = record['alert']
        notification.badge        = record['badge']
        notification.sound        = record['sound']

        @apns.write(notification)
      end
    end
  end
end
