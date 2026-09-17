Pod::Spec.new do |s|
  s.name             = 'factory_core'
  s.version          = '0.1.0'
  s.summary          = 'App Factory core Flutter plugin.'
  s.description      = 'Shared native bindings for factory apps (SF Symbol rendering, widget bridge).'
  s.homepage         = 'https://github.com/sratanjee/AppFactory'
  s.license          = { :file => '../LICENSE', :type => 'MIT' }
  s.author           = { 'App Factory' => 'sratanjee@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency         'Flutter'
  s.platform         = :ios, '15.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version    = '5.0'
end
