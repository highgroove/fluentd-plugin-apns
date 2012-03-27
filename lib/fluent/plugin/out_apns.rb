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
      @pem      = conf.fetch('pem')      { raise Fluent::ConfigError }
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

    def format(device_token, alert, badge, sound)
      [device_token, alert, badge, sound].to_msgpack
    end

    def write(chunk)
      chunk.open do |io|
        begin
          MessagePack::Unpackaer.new(io).each do |options|
            Notification.new do |notification|
              notfication.device_token = options['device_token']
              notfication.alert        = options['alert']
              notfication.badge        = options['badge']
              notfication.sound        = options['sound']
            end

            @apns.write(notification)
          end
        rescue EOFError
        end
      end
    end
  end
end
