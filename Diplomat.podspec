Pod::Spec.new do |s|
  s.name         = "Diplomat"
  s.version      = "0.4.1"
  s.summary      = "The third party SDKs unified API lib."
  s.homepage     = "https://github.com/cloudorz/Diplomat"
  s.license      = { :type => 'MIT License', :file => 'LICENSE' }
  s.author       = { "Cloud" => "cloudcry@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/cloudorz/Diplomat.git", :tag => "#{s.version}" }
  s.frameworks = "SystemConfiguration", "ImageIO", "CoreTelephony"
  s.libraries = "stdc++", "sqlite3", "z"
  s.requires_arc = true
  s.module_map = "Sources/module.modulemap"

  s.subspec 'Core' do |core|
    core.source_files = "Sources/*.{h,m}"
    core.resources = "Sources/*.md"
    core.public_header_files = "Sources/*.h"
  end

  s.subspec 'Weibo' do |weibo|
    weibo.dependency 'Diplomat/Core'
    weibo.source_files = "Sources/Weibo/*.{h,m}"
    weibo.resources = "Sources/Weibo/*.bundle"
    weibo.vendored_libraries = "Sources/Weibo/*.a"
    weibo.public_header_files = "Sources/Weibo/*.h"
  end

  s.subspec 'Wechat' do |wechat|
    wechat.dependency 'Diplomat/Core'
    wechat.source_files = "Sources/Wechat/*.{h,m}"
    wechat.vendored_libraries = "Sources/Wechat/*.a"
    wechat.public_header_files = "Sources/Wechat/*.h"
  end

  s.subspec 'Tencent' do |tencent|
    tencent.dependency 'Diplomat/Core'
    tencent.source_files = "Sources/Tencent/*.{h,m}"
    tencent.vendored_frameworks = "Sources/Tencent/TencentOpenAPI.framework"
    tencent.public_header_files = "Sources/Tencent/*.h"
  end
  
end
