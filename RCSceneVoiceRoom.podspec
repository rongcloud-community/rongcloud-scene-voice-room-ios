
Pod::Spec.new do |s|

# 1 - Info
s.name             = 'RCSceneVoiceRoom'
s.version          = '0.0.1'
s.summary          = 'Scene Voice Room'
s.description      = "Scene Voice Room module"
s.homepage         = 'https://github.com/rongcloud'
s.license      = { :type => "Copyright", :text => "Copyright 2022 RongCloud" }
s.author           = { 'shaoshuai' => 'shaoshuai@rongcloud.cn' }
s.source           = { :git => 'https://github.com/rongcloud-community/rongcloud-scene-voice-room-ios.git', :tag => s.version.to_s }

# 2 - Version
s.ios.deployment_target = '13.0'
s.swift_version = '5.0'
s.static_framework = true

# 3 - config
s.pod_target_xcconfig = {
'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
'VALID_ARCHS' => 'arm64 x86_64',
'SWIFT_COMPILATION_MODE' => 'Incremental',
}

# 4 - source
s.source_files = 'RCSceneVoiceRoom/Classes/**/*'

# 5 - dependency
s.dependency 'SnapKit'
s.dependency 'Reusable'
s.dependency 'Pulsator'
s.dependency 'ReactorKit'
s.dependency 'Kingfisher'
s.dependency 'MJRefresh'
s.dependency 'XCoordinator'
s.dependency 'IQKeyboardManager'

s.dependency 'RCSceneRoom'
s.dependency 'RCSceneChat'
s.dependency 'RCSceneGift'
s.dependency 'RCSceneMusic'
s.dependency 'RCSceneRoomSetting'
s.dependency 'RCVoiceRoomLib'

end
