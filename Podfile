platform :ios, '9.0'

target 'Suup' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Suup

pod 'Firebase'
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'Firebase/Storage'
pod 'SVProgressHUD'
pod 'ChameleonFramework'
pod 'FirebaseMessaging'
pod 'Alamofire', '~> 4.7'


end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
        end
    end
end
