#
# Be sure to run `pod lib lint CoreBase.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CoreBase'
  s.version          = '0.1.0'
  s.summary          = 'Clean Architecture'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
iOS project code-base inspired by modern architectures: Redux, RIBs
                       DESC

  s.homepage         = 'https://github.com/dungntm58/iOSCore'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  # s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dungntm58' => 'minhdung.uet.work@gmail.com' }
  s.source           = { :git => 'https://github.com/dungntm58/iOSCore', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'
  s.module_name = 'CoreBase'
  s.swift_version = "5.2"
  s.prefix_header_file = false
  s.framework = "Foundation", "Combine"
  s.ios.framework = "UIKit"

  s.default_subspecs = 'Basics', 'Scene'
  
  s.subspec 'Basics' do |ss|
    ss.source_files = 'Sources/Base/Basics/**/*'
  end
  
  s.subspec 'Scene' do |ss|
    ss.source_files = 'Sources/Base/Scene/**/*.{h,m,mm,swift}'
    ss.private_header_files = 'Sources/Base/Scene/**/*+Internal.h'
  end
  
  s.subspec 'ReduxExtension' do |ss|
    ss.source_files = 'Sources/Base/ReduxExtension/**/*.{h,m,mm,swift}'
    ss.dependency 'CoreBase/Scene'
    ss.dependency 'CoreRedux'
  end
end
