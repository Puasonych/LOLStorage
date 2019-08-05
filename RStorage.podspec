Pod::Spec.new do |spec|
  spec.name               = 'RStorage'
  spec.version            = '1.2.2'
  spec.summary            = 'UserDefaults abstraction framework with caching'
  spec.homepage           = 'https://github.com/ephedra-software/RStorage'
  spec.license            = { :type => 'MIT', :file => 'LICENSE' }
  spec.author             = { 'Erik Basargin' => 'basargin.erik@gmail.com' }
  spec.social_media_url   = 'https://twitter.com/Puasonych'
  spec.source             = { :git => 'https://github.com/ephedra-software/RStorage.git', :tag => spec.version }
  spec.swift_version      = '5.0'

  spec.ios.deployment_target  = '8.0'

  spec.default_subspec = 'Core'

  spec.subspec 'Core' do |subspec|
    subspec.source_files = 'RStorage/*.swift'
    subspec.framework = 'Foundation'
  end
end
