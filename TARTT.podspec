#
# Be sure to run `pod lib lint TARTT.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "TARTT"
  s.version          = "0.1.0"
  s.summary          = "Integration of TARTT Web for iOS."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = "Integration of TARTT Web for iOS. Wikitude is required for this to work."

  s.homepage         = "https://github.com/takondi/tartt-sdk-ios"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "wh33ler" => "opiolka.thomas@googlemail.com" }
  s.source           = { :git => "https://github.com/takondi/tartt-sdk-ios.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'TARTT' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.library = 'sqlite3','z'
  s.dependency 'AFNetworking', '~> 2.0'
  s.dependency 'AWSDynamoDB', '~> 2.2.0'
  s.dependency 'AWSCore'
#  s.dependency 'ZBarSDK'
end
