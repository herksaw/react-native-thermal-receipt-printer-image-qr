require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = 'react-native-thermal-receipt-printer-image-qr'
  s.version      = package['version']
  s.summary      = package['description']
  s.description  = <<-DESC
                  react-native-thermal-receipt-printer-image-qr
                   DESC
  s.license      = 'MIT'
  # s.license    = { :type => "MIT", :file => "LICENSE" }

  s.authors      = { 'Your Name' => 'yourname@email.com' }
  s.homepage     = 'https://github.com/github_account/react-native-thermal-receipt-printer-image-qr'
  s.platforms    = { :ios => '9.0' }

  s.source       = { :git => 'https://github.com/github_account/react-native-thermal-receipt-printer-image-qr.git', :tag => "v#{s.version}" }
  s.source_files = 'ios/**/*.{h,m,swift}'
  s.requires_arc = true

  s.resources    = ["ios/GPrinterLegacy/GSDK/GSDK.framework"]
  s.vendored_frameworks = "ios/GPrinterLegacy/GSDK/GSDK.framework"
  
  # # Framework configuration
  # s.ios.vendored_frameworks = '${PODS_ROOT}/../../../../ios/Frameworks/IOS_SWIFT_WIFI_SDK.xcframework'
  # s.preserve_paths = '${PODS_ROOT}/../../../../ios/Frameworks/IOS_SWIFT_WIFI_SDK.xcframework'
  
  # Other configurations
  s.ios.vendored_libraries = 'ios/PrinterSDK/libPrinterSDK.a'
  # s.xcconfig = { 
  #   'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/../ios/PrinterSDK"/** "${PODS_ROOT}/../../../../ios/Frameworks/IOS_SWIFT_WIFI_SDK.xcframework/ios-arm64/Headers"',
  #   'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}/../../../../ios/Frameworks"'
  # }
  s.xcconfig = { 
    'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/../ios/PrinterSDK"/**',
    'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}/../../../../ios/Frameworks"'
  }

  # # Add Swift version and module settings
  # s.swift_version = '5.0'
  # s.pod_target_xcconfig = {
  #   'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/../../../../ios/Frameworks/IOS_SWIFT_WIFI_SDK.xcframework/ios-arm64/Headers',
  #   'OTHER_LDFLAGS' => '-framework IOS_SWIFT_WIFI_SDK'
  # }

  s.dependency 'React'
  # s.dependency "..."
end
