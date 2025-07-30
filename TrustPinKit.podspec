Pod::Spec.new do |spec|
  spec.name         = "TrustPinKit"
  spec.version      = "0.4.2"
  spec.summary      = "TrustPin iOS SDK for certificate pinning and security"
  spec.description  = <<-DESC
                    TrustPin provides advanced certificate pinning and network security
                    capabilities for iOS applications, ensuring secure communication
                    and protection against man-in-the-middle attacks.
                    DESC

  spec.homepage     = "https://github.com/trustpin-cloud/TrustPin-Swift.binary"
  spec.license      = { :type => "Custom", :text => "TrustPin Binary License Agreement - See https://trustpin.cloud for full terms" }
  spec.author       = { "TrustPin" => "support@trustpin.cloud" }

  spec.ios.deployment_target = "13.0"
  spec.osx.deployment_target = "13.0"
  spec.watchos.deployment_target = "7.0"
  spec.tvos.deployment_target = "13.0"

  spec.source       = { :http => "https://github.com/trustpin-cloud/TrustPin-Swift.binary/releases/download/0.4.2/TrustPinKit-0.4.2.xcframework.zip" }
  spec.vendored_frameworks = "TrustPinKit.xcframework"

  spec.framework = "Foundation"
  spec.swift_version = "6.1"
end
