#
# Be sure to run `pod lib lint CoreRequest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CoreRepository-Rx'
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

  s.default_subspecs = 'Basics', 'DataStore', 'Request', 'Remote', 'Local', 'RemoteLocal'

  s.subspec 'Basics' do |ss|
    ss.source_files = 'Sources/Repository/Shared/Basics/**/*', 'Sources/Repository/Rx/Basics/**/*'
    ss.ios.deployment_target = '10.0'
    ss.dependency 'RxSwift', '~>6.0.0'
  end

  s.subspec 'DataStore' do |ss|
    ss.source_files = 'Sources/Repository/Shared/DataStore/**/*', 'Sources/Repository/Rx/DataStore/**/*'
    ss.ios.deployment_target = '10.0'
    ss.dependency 'CoreRepository-Rx/Basics'
  end

  s.subspec 'Request' do |ss|
    ss.source_files = 'Sources/Repository/Shared/Request/**/*', 'Sources/Repository/Rx/Request/**/*'
    ss.ios.deployment_target = '10.0'
    ss.dependency 'Alamofire'
    ss.dependency 'CoreRepository-Rx/Basics'
  end

  s.subspec 'Remote' do |ss|
    ss.source_files = 'Sources/Repository/Shared/Remote/**/*', 'Sources/Repository/Rx/Remote/**/*'
    ss.ios.deployment_target = '10.0'
    ss.dependency 'CoreRepository-Rx/Basics'
    ss.dependency 'CoreRepository-Rx/Request'
  end

  s.subspec 'Local' do |ss|
    ss.source_files = 'Sources/Repository/Shared/Local/**/*', 'Sources/Repository/Rx/Local/**/*'
    ss.ios.deployment_target = '10.0'
    ss.dependency 'CoreRepository-Rx/Basics'
    ss.dependency 'CoreRepository-Rx/DataStore'
  end

  s.subspec 'RemoteLocal' do |ss|
    ss.source_files = 'Sources/Repository/Shared/RemoteLocal/**/*', 'Sources/Repository/Rx/RemoteLocal/**/*'
    ss.ios.deployment_target = '10.0'
    ss.dependency 'CoreRepository-Rx/Remote'
    ss.dependency 'CoreRepository-Rx/Local'
  end
end
