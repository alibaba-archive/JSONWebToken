#
#  Created by teambition-ios on 2020/7/27.
#  Copyright © 2020 teambition. All rights reserved.
#     

Pod::Spec.new do |s|
  s.name             = 'TBJSONWebToken'
  s.version          = '3.2.0'
  s.summary          = 'Swift implementation of JSON Web Token.'
  s.description      = <<-DESC
  Swift implementation of JSON Web Token.
                       DESC

  s.homepage         = 'https://github.com/teambition/JSONWebToken'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'teambition mobile' => 'teambition-mobile@alibaba-inc.com' }
  s.source           = { :git => 'https://github.com/teambition/JSONWebToken.git', :tag => s.version.to_s }

  s.swift_version = '5.0'
  s.ios.deployment_target = '8.0'

  s.source_files = 'Source/*.swift'
  s.dependency 'CryptoSwift', '~> 1.0.0'
end
