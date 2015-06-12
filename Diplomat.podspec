Pod::Spec.new do |s|
  s.name         = "Diplomat"
  s.version      = "0.2"
  s.summary      = "lls used third party SDK."
  s.description  = <<-DESC
                    Thrid party SDK collector

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/cloudorz/Diplomat/wiki"
  s.license      = "MIT"
  s.author             = { "Cloud" => "cloudcry@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/cloudorz/Diplomat.git", :tag => "#{s.version}" }
  s.frameworks = "SystemConfiguration", "ImageIO"
  s.libraries = "stdc++", "sqlite3", "z"
  s.requires_arc = true

  s.subspec 'Core' do |core|
    core.dependency 'UIImage-ResizeMagick'
    core.source_files = "Sources/*.{h, m}"
  end

  s.subspec 'Weibo' do |weibo|
    weibo.dependency 'Diplomat/Core'
    weibo.source_files = "Sources/Weibo/*.{h, m}"
    weibo.resources = "Sources/Weibo/*.bundle"
    weibo.vendored_libraries = "Sources/Weibo/*.a"
  end

  s.subspec 'Wechat' do |wechat|
    wechat.dependency 'Diplomat/Core'
    wechat.source_files = "Sources/Wechat/*.{h, m}"
    wechat.vendored_libraries = "Sources/Wechat/*.a"
  end

  s.subspec 'Tencent' do |tencent|
    tencent.dependency 'Diplomat/Core'
    tencent.source_files = "Sources/Tencent/*.{h, m}"
    tencent.vendored_libraries = "Sources/Tencent/*.a"
  end
  
end
