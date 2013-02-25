#!/usr/local/bin/ruby

# https://github.com/jpoz/APNS

require 'apns'

APNS.pem = 'cert.pem'

#iPad mini
#device_token = '0091c2f1aeec371b494b9333c08d34be659fb0f4522df7526321cc9e18f46e2c'

#iPhone 3GS
#device_token = '6df912b30e3cd93c61fea948f92fc6f97551fb1721d6bf490e60cf707163d22f'

#iPhone 4
#device_token = 'feabd59f5a7575ccbcd484e04f81f95d824b681ba0c7470b766527c31af7ab0f'

#iPhone 4S
#device_token = 'd72439561e9958e9e2d962419a4a3e03887e2fcbb0da6ff9a20964230dd22c77'

#iPhone 5
device_token = '886d341635b34ba0d1433b43e5611b52e9cc4d34ff20b737086646849e972914'

APNS.send_notification(device_token,
                       :alert => 'Hello iPhone!',
                       :badge => 1,                       
                       :sound => 'PikaPika30sec.wav')
                       #                       :sound => 'default')
