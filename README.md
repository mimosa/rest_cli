
## Installing

Add to your `Gemfile`:

```ruby
gem 'rest_cli'
```

Then `bundle install`.

Or install it yourself as:

    $ gem install rest_cli

## Usage

```ruby
require 'adapters/bilibili_api'
require 'adapters/bilibili_player'

yestoday = (Date.today-1)
b = BilibiliApi.new(yestoday)
p = BilibiliPlayer.new

episodes = b.episodes_by_name('搞笑')

File.open('bili_#{yestoday}.json', 'wb') do |f|
  f.write MultiJson.dump(episodes: episodes) 
end unless episodes.nil?

video_url = p.video_url('av290914')

comments = b.comments_by_id('av290914')
```

```ruby
require 'adapters/kuaidi100'

k = Kuaidi100.new
k.trace(611382431237)
```
> 
  ```json
   {
    "status": true,
    "shipping_method": "顺丰",
    "tracking_no": 611382431237,
    "routes": [
      ...
      {
        "time": "2016-11-22 23:19:42", 
        "ftime": "2016-11-22 23:19:42", 
        "context": "快件到达 【上海虹桥集散中心2】"
      },
      ...
    ],
    "state": "签收"
  }
   ```


```ruby
require 'adapters/yun_pian'

y = YunPian.new(apikey)
y.send(mobile, text, sign)
```

```ruby
require 'adapters/ipeen'

i = Ipeen.new

users = i.users
```
> 
  ```json
  {
    ...
    "littleg": {
      "avatar_url": "http://iphoto.ipeen.com.tw/photo/usr/55900/usr55900_200.jpg",
      "nickname": "雞寶"
    }
    ...
  }
  ```
