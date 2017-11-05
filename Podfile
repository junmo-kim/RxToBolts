# Uncomment the next line to define a global platform for your project
platform :ios, '8.0'

# ignore all warnings from all pods
inhibit_all_warnings!

target 'RxToBolts' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for RxToBolts
  pod 'RxSwift', '~> 4.0'
  pod 'Bolts', '~> 1.8'

  target 'RxToBoltsTests' do
    inherit! :search_paths
    # Pods for testing

    pod 'Quick', '~> 1.2'
    pod 'Nimble', '~> 7.0'
  end

end


post_install do |installer|
  puts 'Removing static analyzer support for pods'
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['OTHER_CFLAGS'] = "$(inherited) -Qunused-arguments -Xanalyzer -analyzer-disable-all-checks"
      config.build_settings['CLANG_ENABLE_CODE_COVERAGE'] = 'NO'
    end
  end
end
