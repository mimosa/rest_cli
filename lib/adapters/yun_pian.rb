# -*- encoding: utf-8 -*-
require 'rest_cli'

class YunPian < RestCli
  def initialize(key)
    @params = {
      apikey: key
    }

    super('https://sms.yunpian.com/v2')
  end

  def send(mobile, content, sign)
    raw = send_sms(mobile, "#{content}【#{sign}】")
    raw && raw[:code].zero?
  end

  private

  def send_sms(mobile, message)
    self.post('sms/single_send.json', {
      mobile: mobile,
      text: message
    }.merge(@params))
  end
end
