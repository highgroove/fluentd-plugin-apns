require 'test_helper'

class ApnsOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
    require 'fluent/plugin/out_apns'
  end

  def create_driver(conf = '')
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::ApnsOutput).configure(conf)
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
    conf = '
      pem /root/.ssh/apns.pem
    '

    driver = create_driver(conf)

    assert_equal(driver.instance.host,     'gateway.sandbox.push.apple.com')
    assert_equal(driver.instance.port,     2195)
    assert_equal(driver.instance.pem,      '/root/.ssh/apns.pem')
    assert_equal(driver.instance.password, nil)
  end

  def test_configure_without_pem
    assert_raise Fluent::ConfigError do
      create_driver
    end
  end
end
