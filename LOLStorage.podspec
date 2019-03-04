Pod::Spec.new do |spec|
  spec.name               = 'LOLStorage'
  spec.version            = '1.0'
  spec.summary            = 'UserDefaults abstraction framework with caching'
  spec.homepage           = 'https://github.com/Puasonych/LOLStorage'
  spec.license            = { :type => 'MIT' }
  spec.author             = { 'Erik Basargin' => 'basargin.erik@gmail.com' }
  spec.social_media_url   = 'https://twitter.com/Puasonych'
  spec.source             = { :git => "https://github.com/Puasonych/LOLStorage.git", :tag => "v1.0" }
  spec.swift_version      = '4.2'

  spec.ios.deployment_target  = '8.0'

  spec.default_subspec = "Core"

  spec.subspec "Core" do |subspec|
    subspec.source_files = "LOLStorage/*.swift"
    subspec.framework = "UIKit"
  end
end
