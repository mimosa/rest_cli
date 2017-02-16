# -*- encoding: utf-8 -*-
require 'rest_cli'

class Kuaidi100 < RestCli
  
  def initialize
    super('http://m.kuaidi100.com')
  end

  def trace(no, shipping_method = nil)
    code = providers[shipping_method] || find_code(no)
    return tracking(no, code) unless code.nil?

    { status: false, message: '快递公司参数异常：单号不存在或者已经过期' }
  end

  def find_code(no)
    raw = self.post('/autonumber/auto', { num: no }, headers(no))
    raw.shift.delete(:comCode) unless raw.nil?
  end

  def tracking(no, code)
    raw = self.get('/query', { type: code, postid: no }, headers(no))
    if raw.nil?
      { status: false, message: '服务器出错。' }
    elsif raw[:status] == '200'
      { 
        status: true, 
        shipping_method: codes[code], 
        tracking_no: no, 
        routes: raw[:data],
        state:  states[raw[:state]]
      }
    else
      { status: false, message: raw[:message] }
    end
  end

  private

    def headers(no)
      {
        host: 'm.kuaidi100.com',
        origin: 'http://m.kuaidi100.com',
        referer: "http://m.kuaidi100.com/result.jsp?nu=#{no}",
        accept: 'application/json;level=1'
      }
    end

    def codes
      {
        'quanfengkuaidi' => '全峰',
        'rufengda' => '如风达',
        'shentong' => '申通',
        'shunfeng' => '顺丰',
        'yuantong' => '圆通',
        'yunda' => '韵达',
        'zhongtong' => '中通',
        'zhaijisong' => '宅急送',
      }
    end

    def providers
      codes.invert
    end

    def states
      {
        '0' => '在途', # 即货物处于运输过程中；
        '1' => '揽件', # 货物已由快递公司揽收并且产生了第一条跟踪信息；
        '2' => '疑难', # 货物寄送过程出了问题；
        '3' => '签收', # 收件人已签收；
        '4' => '退签', # 即货物由于用户拒签、超区等原因退回', 而且发件人已经签收；
        '5' => '派件', # 即快递正在进行同城派件；
        '6' => '退回', # 货物正处于退回发件人的途中；
      }
    end
end