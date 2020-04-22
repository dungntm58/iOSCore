#
# Be sure to run `pod lib lint CoreRequest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CoreRepository'
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
  s.module_name = 'CoreRepository'
  s.swift_version = "5.2"
  s.framework = "Foundation"

  s.default_subspecs = 'BasicsRx', 'DataStoreRx', 'RequestRx', 'RemoteRx', 'LocalRx', 'RemoteLocalRx'
  
  s.subspec 'BasicsCombine' do |ss|
    ss.source_files = 'Sources/Repository/Shared/Basics/**/*', 'Sources/Repository/Combine/Basics/**/*', 'Sources/Shared/**/*.swift'
    ss.exclude_files = 'Sources/Repository/Shared/Basics/Shared/**/*'
    ss.ios.deployment_target = '13.0'
    ss.framework = 'Combine'
  end

  s.subspec 'DataStoreCombine' do |ss|
    ss.source_files = 'Sources/Repository/Shared/DataStore/**/*', 'Sources/Repository/Combine/DataStore/**/*'
    ss.ios.deployment_target = '13.0'
    ss.framework = 'Combine'
    ss.dependency 'CoreRepository/BasicsCombine'
  end

  s.subspec 'RequestCombine' do |ss|
    ss.source_files = 'Sources/Repository/Shared/Request/**/*', 'Sources/Repository/Combine/Request/**/*'
    ss.ios.deployment_target = '13.0'
    ss.framework = 'Combine'
    ss.dependency 'Alamofire'
    ss.dependency 'CoreRepository/BasicsCombine'
  end

  s.subspec 'RemoteCombine' do |ss|
    ss.source_files = 'Sources/Repository/Combine/Remote/**/*'
    ss.ios.deployment_target = '13.0'
    ss.framework = 'Combine'
    ss.dependency 'CoreRepository/BasicsCombine'
    ss.dependency 'CoreRepository/RequestCombine'
  end

  s.subspec 'LocalCombine' do |ss|
    ss.source_files = 'Sources/Repository/Combine/Local/**/*'
    ss.ios.deployment_target = '13.0'
    ss.framework = 'Combine'
    ss.dependency 'CoreRepository/BasicsCombine'
    ss.dependency 'CoreRepository/DataStoreCombine'
  end

  s.subspec 'RemoteLocalCombine' do |ss|
    ss.source_files = 'Sources/Repository/Combine/RemoteLocal/**/*'
    ss.ios.deployment_target = '13.0'
    ss.framework = 'Combine'
    ss.dependency 'CoreRepository/RemoteCombine'
    ss.dependency 'CoreRepository/LocalCombine'
  end

  s.subspec 'BasicsRx' do |ss|
    ss.source_files = 'Sources/Repository/Shared/Basics/**/*', 'Sources/Repository/Rx/Basics/**/*', 'Sources/Shared/**/*.swift'
    ss.exclude_files = 'Sources/Repository/Shared/Basics/Shared/**/*'
    ss.ios.deployment_target = '10.0'
  end

  s.subspec 'DataStoreRx' do |ss|
    ss.source_files = 'Sources/Repository/Shared/DataStore/**/*', 'Sources/Repository/Rx/DataStore/**/*'
    ss.ios.deployment_target = '10.0'
    ss.dependency 'CoreRepository/BasicsRx'
  end

  s.subspec 'RequestRx' do |ss|
    ss.source_files = 'Sources/Repository/Shared/Request/**/*', 'Sources/Repository/Rx/Request/**/*'
    ss.ios.deployment_target = '10.0'
    ss.dependency 'Alamofire'
    ss.dependency 'CoreRepository/BasicsRx'
  end

  s.subspec 'RemoteRx' do |ss|
    ss.source_files = 'Sources/Repository/Rx/Remote/**/*'
    ss.ios.deployment_target = '10.0'
    ss.dependency 'CoreRepository/BasicsRx'
    ss.dependency 'CoreRepository/RequestRx'
  end

  s.subspec 'LocalRx' do |ss|
    ss.source_files = 'Sources/Repository/Rx/Local/**/*'
    ss.ios.deployment_target = '10.0'
    ss.dependency 'CoreRepository/BasicsRx'
    ss.dependency 'CoreRepository/DataStoreRx'
  end

  s.subspec 'RemoteLocalRx' do |ss|
    ss.source_files = 'Sources/Repository/Rx/RemoteLocal/**/*'
    ss.ios.deployment_target = '10.0'
    ss.dependency 'CoreRepository/RemoteRx'
    ss.dependency 'CoreRepository/LocalRx'
  end
end
