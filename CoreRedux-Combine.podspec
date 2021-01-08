#
# Be sure to run `pod lib lint CoreRedux.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CoreRedux-Combine'
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

  s.platform = :ios
  s.module_name = 'CoreRedux'
  s.swift_version = "5.2"
  s.prefix_header_file = false
  s.framework = "Foundation"

  s.default_subspecs = 'Basics'
  
  s.subspec 'Basics' do |ss|
    ss.source_files = 'Sources/Redux/Shared/Basics/**/*', 'Sources/Redux/Combine/Basics/**/*'
    ss.ios.deployment_target = '13.0'
    ss.framework = 'Combine'
  end
  
  s.subspec 'List' do |ss|
    ss.source_files = 'Sources/Redux/Shared/List/**/*', 'Sources/Redux/Combine/List/**/*'
    ss.ios.deployment_target = '13.0'
    ss.framework = 'Combine'
    ss.dependency 'CoreRepository-Combine/Basics'
    ss.dependency 'CoreRedux-Combine/Basics'
  end
end
