require 'webmock/cucumber'

WebMock.disable_net_connect!(allow: 'graph.facebook.com', allow_localhost: true)
