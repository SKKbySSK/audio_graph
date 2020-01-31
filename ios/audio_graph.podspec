#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint audio_graph.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'audio_graph'
  s.version          = '0.0.5'
  s.summary          = 'Flutter plugin to build custom audio graph'
  s.description      = <<-DESC
Flutter plugin to build custom audio graph
                       DESC
  s.homepage         = 'https://github.com/SKKbySSK/audio_engine'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'skkbyssk@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
