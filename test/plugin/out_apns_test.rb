require 'test_helper'

class ApnsOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
    require 'fluent/plugin/out_apns'
  end

  def default_configuration
    <<-EOC
      pem /root/.ssh/apns.pem
    EOC
  end

  def empty_configuration
    ''
  end

  def create_driver(conf = '')
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::ApnsOutput).configure(conf)
  end

  def stub_apns
    stub_everything.tap do |apns|
      ApnServer::Client.stubs(:new).returns(apns)
    end
  end

  def test_configure_options
    conf = '
      host     gateway.push.apple.com
      port     2196
      pem      /root/.ssh/apns.pem
      password NcFYy6JpQ5Us
    '

    driver = create_driver(conf)

    assert_equal(driver.instance.host,     'gateway.push.apple.com')
    assert_equal(driver.instance.port,     2196)
    assert_equal(driver.instance.pem,      '/root/.ssh/apns.pem')
    assert_equal(driver.instance.password, 'NcFYy6JpQ5Us')
  end

  def test_configure_defaults
    driver = create_driver(default_configuration)

    assert_equal(driver.instance.host,     'gateway.sandbox.push.apple.com')
    assert_equal(driver.instance.port,     2195)
    assert_equal(driver.instance.password, nil)
  end

  def test_configure_without_pem
    assert_raise Fluent::ConfigError do
      create_driver(empty_configuration)
    end
  end

  def test_start_connects_to_apns
    apns   = stub_apns
    driver = create_driver(default_configuration)

    apns.expects(:connect!)
    driver.instance.start
  end

  def test_shutdown_disconnects_from_apns
    apns   = stub_apns
    driver = create_driver(default_configuration)

    apns.expects(:disconnect!)
    driver.instance.start # must be started before being shutdown
    driver.instance.shutdown
  end

  def test_writes_to_apns
    apns   = stub_apns
    driver = create_driver(default_configuration)

    apns.expects(:write).with { |notification|
      notification.device_token == "abc123" &&
      notification.alert        == "EXERCISE EXERCISE EXERCISE" &&
      notification.badge        == 1 &&
      notification.sound        == "siren.aiff"
    }

    driver.emit(
      "device_token" => "abc123",
      "alert"        => "EXERCISE EXERCISE EXERCISE",
      "badge"        => 1,
      "sound"        => "siren.aiff"
    )
    driver.run
  end
end
