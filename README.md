koko-ai-ruby
==============

koko-ai-ruby is a ruby client for https://docs.koko.ai

## Install

Into Gemfile from rubygems.org:
```ruby
gem 'koko-ai'
```

Into environment gems from rubygems.org:
```ruby
gem install 'koko-ai'
```

## Usage

Create an instance of the client:
```ruby
koko = Koko::Tracker.new(auth: 'YOUR_AUTH_KEY')
```

Track content, flags and moderations, see more [here](https://docs.koko.ai/#track-endpoints).
```ruby
koko.track_content(id: "123",
                   created_at: Time.now,
                   user_id: "123",
                   type: "post",
                   context_id: "123",
                   content_type: "text",
                   content: { text: "Some content" })

koko.track_flag(id: "123",
                flagger_id: "123",
                type: "spam",
                created_at: Time.now,
                targets: [{content_id: "123"}])

koko.track_moderation(id: "123",
                      type: "user_warned",
                      created_at: Time.now,
                      targets: [{content_id: "123" }])

```

To get behavorial classifications when tracking content, pass the classifiers
you want run as an options param
```ruby
classifications = koko.track_content(id: "123",
                                     created_at: Time.now,
                                     user_id: "123",
                                     type: "post",
                                     context_id: "123",
                                     content_type: "text",
                                     content: { text: "Some content" },
                                     options: { classifiers: ['crisis'] })

```

## Testing

You can use the `stub` option to Koko::Tracker.new to cause all requests to be stubbed, making it easier to test with this library.

## License

```
WWWWWW||WWWWWW
 W W W||W W W
      ||
    ( OO )__________
     /  |           \
    /o o|    MIT     \
    \___/||_||__||_|| *
         || ||  || ||
        _||_|| _||_||
       (__|__|(__|__|
```

(The MIT License)

Copyright (c) 2017 Koko Inc. <us@itskoko.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
