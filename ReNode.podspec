#
# Be sure to run `pod lib lint ReNode.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'ReNode'
    s.version          = '0.2.44'
    s.summary          = 'A library component with common use for developing swift project.'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    A common library contains ready made components for fast development
    combines RxSwift, ReSwift in a single package with components made from AsyncDisplayKit(Texture).
    DESC
    
    s.homepage         = 'https://github.com/moribaleta/ReNode.git'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { '13190143' => 'moribaleta.work@gmail.com' }
    s.source           = { :git => 'https://github.com/moribaleta/ReNode.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.ios.deployment_target = '11'
    s.swift_version = '5'
    s.source_files  = 'ReNode/Classes/**/*'
    s.resources     = 'ReNode/Assets/*.{ttf}'
    
    s.dependency "Texture", '~> 3.0.0'
    s.dependency "ReSwift"
    s.dependency "ReSwiftThunk"
    s.dependency "RxSwift", '~> 6.2.0'
    s.dependency "RxCocoa", '~> 6.2.0'
    s.dependency "RxKeyboard"
    s.dependency "DateTools"
    s.dependency "SnapKit"
    s.dependency "SVGgh"
    
    s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(FRAMEWORK_SEARCH_PATHS)/Texture.framework/Headers" }
    s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(FRAMEWORK_SEARCH_PATHS)/ReSwift.framework/Headers" }
    s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(FRAMEWORK_SEARCH_PATHS)/RxSwift.framework/Headers" }
    s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(FRAMEWORK_SEARCH_PATHS)/RxCocoa.framework/Headers" }
    s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(FRAMEWORK_SEARCH_PATHS)/RxKeyboard.framework/Headers" }
    s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(FRAMEWORK_SEARCH_PATHS)/ReSwiftThunk.framework/Headers" }
    s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(FRAMEWORK_SEARCH_PATHS)/DateTools.framework/Headers" }
    s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(FRAMEWORK_SEARCH_PATHS)/SnapKit.framework/Headers" }
    s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(FRAMEWORK_SEARCH_PATHS)/SVGgh.framework/Headers" }
    
    
    # s.resource_bundles = {
    #   'ReNode' => ['ReNode/Assets/*.png']
    # }
    
    # s.public_header_files = 'Pod/Classes/**/*.h'
    # s.frameworks = 'UIKit', 'MapKit'
    # s.dependency 'AFNetworking', '~> 2.3'
end
