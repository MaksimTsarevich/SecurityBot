# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'SecurityBot' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SecurityBot

end

target 'TrackerBlocker' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TrackerBlocker
	pod 'lottie-ios'
  	#pod 'CircleProgressView', '~> 1.0'
	#pod 'Adapty', '~> 2.3.3'
	pod 'CocoaImageHashing'
	pod "TLPhotoPicker"
	pod 'NDT7', '0.0.4'
	pod 'KeychainSwift', '~> 20.0'
	pod 'Kingfisher'
	pod 'PanModal'
	pod 'MTCircleChart'
	
	
post_install do |installer|
	installer.generated_projects.each do |project|
		project.targets.each do |target|
			target.build_configurations.each do |config|
				config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
			end
		end
	end 
 end
end
