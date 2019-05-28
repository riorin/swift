# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'LoginDemo' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for LoginDemo
  pod 'UIScrollView-InfiniteScroll', '~> 1.0.0'
  
  pod 'RealmSwift'
  pod 'Moya/RxSwift', '~> 11.0'
  pod 'Kingfisher', '~> 4.0'
  pod 'KeychainSwift', '~> 11.0'
  
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  
  target 'LoginDemo-Dev' do
      inherit! :search_paths
      # Pods for testing
  end
      
  target 'LoginDemoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'LoginDemoUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'NotificationService' do
  use_frameworks!

  pod 'Kingfisher', '~> 4.0'
end
