Pod::Spec.new do |s|
  s.name         = 'jl_dfu'
  s.version      = '0.0.1'
  s.summary      = 'Flutter plugin for Jieli OTA (DFU) functionality using JL OTA SDK.'
  s.description  = <<-DESC
    Flutter plugin that wraps the Jieli OTA SDK for performing firmware updates on Jieli Bluetooth chips.
    Only includes OTA functions. Scanning and connection must be handled by the app (e.g. using flutter_blue_plus).
  DESC
  s.homepage     = 'https://github.com/waitwalker/jl_dfu'
  s.license      = { :file => '../LICENSE' }
  s.author       = { 'jl_dfu' => 'developer@example.com' }
  s.platform     = :ios, '11.0'
  s.source       = { :path => '.' }
  s.public_header_files = 'Classes/**/*.h'
  s.source_files = 'Classes/**/*.{h,m,swift}'
  # Frameworks from the Jieli OTA SDK that are required for OTA functionality. You must add these frameworks into ios/Frameworks.
  s.vendored_frameworks = [
    'Frameworks/JL_OTALib.framework',
    'Frameworks/JL_AdvParse.framework',
    'Frameworks/JL_HashPair.framework'
  ]
  s.swift_version = '5.0'
  s.dependency 'Flutter'
end
