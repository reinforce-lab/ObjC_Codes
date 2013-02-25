#!/usr/bin/ruby
# http://iphone.longearth.net/2009/09/01/【iphone】push-notificationの実装方法/

require 'openssl'
require 'socket'

device = ['0091c2f1aeec371b494b9333c08d34be659fb0f4522df7526321cc9e18f46e2c']

socket = TCPSocket.new('gateway.sandbox.push.apple.com',2195)

context = OpenSSL::SSL::SSLContext.new('SSLv3')
context.cert = OpenSSL::X509::Certificate.new(File.read('apns-dev.pem'))
context.key  = OpenSSL::PKey::RSA.new(File.read('apns-dev-key-noenc.pem'))

ssl = OpenSSL::SSL::SSLSocket.new(socket, context)
ssl.connect

payload = <<-EOS
{
    "aps":{
        "alert":"New Message!",
        "badge":1,
        #        "sound":"default"
        #        "sound":"PikaPika30sec.wav"
    }
}
EOS
(message = []) << ['0'].pack('H') << [32].pack('n') << device.pack('H*') << [payload.size].pack('n') << payload


ssl.write(message.join(''))
ssl.close
socket.close
