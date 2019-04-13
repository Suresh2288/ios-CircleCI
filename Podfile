
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'Plano' do
    
    pod 'Fabric' #Analytics/Crash
    pod 'Crashlytics'

    pod 'FirebaseCore', '~> 4.0'
    pod 'GoogleAnalytics'

    pod 'Alamofire' #Network
    pod 'Kingfisher'
    pod 'ReachabilitySwift'
    pod 'HTTPStatusCodes'

    pod 'RealmSwift', '~> 2.8' #Realm
    pod 'SwiftyJSON'
    pod 'ObjectMapper'
    pod 'AlamofireObjectMapper', '~> 4.0'
    pod 'Validator', '~> 3.0'
    
    pod 'FacebookLogin'

    pod 'PKHUD', '~> 4.0'

    pod 'SwiftyUserDefaults'
    #    pod 'PermissionScope'
    pod 'SwiftDate', '~> 4.0' #Dates
    pod 'SwiftHEXColors', '~> 1.1' #easy Hex colors
    pod 'Charts' #Charts
# pod 'Charts/Realm' #Charts+Realm
    pod 'SnapKit', '~> 3.2.0' #Autolayout
    pod 'JDAnimationKit'
    pod 'RSKImageCropper'
    
#    pod 'Spring', :git => 'https://github.com/MengTo/Spring.git', :branch => 'swift3' #animation
#    pod 'Eureka', '~> 2.0.0-beta.1' #Table Forms
    #pod 'Tactile', '~> 1.0' #Gesture
    
    pod 'EAIntroView'
    pod 'Localize-Swift', '~> 1.7'
    pod 'NVActivityIndicatorView'
    #    pod 'Proposer', '~> 1.1.0'
    pod 'Device', '~> 3.0.3' #Device & Screen Sizes
    pod 'SkyFloatingLabelTextField', '~> 2.0.1' #Floating UILabel
    pod 'TPKeyboardAvoiding' #Textfield & Keyboard
    pod 'UIImageViewAlignedSwift'
    pod 'PopupDialog' #Custom Popups
    #    pod 'MotionKit', :git => 'https://github.com/herrkaefer/MotionKit' #Sensors
    
    pod 'XCGLogger', '~> 4.0.0'
    
    #pod 'PNChartSwift' #, :git => 'https://github.com/kevinzhow/PNChart-Swift.git' #Charts
    
    #pod 'CocoaLumberjack/Swift'
    #pod 'PaperTrailLumberjack'
    #pod 'PaperTrailLumberjack/Swift'
    #pod 'PaperTrailLumberjack/Swift' #Logging
    
    #DAExpandAnimation -- for Animation
    
    pod 'SlideMenuControllerSwift'
    pod 'AMScrollingNavbar'
    pod 'ACTabScrollView'
#    pod 'ACTabScrollView'  #View Pager :git => 'https://github.com/htarwara6245/ACTabScrollView.git'
    pod 'JTMaterialSwitch' #UI Switch
    pod 'KDCircularProgress' #Circular Progress View
    pod 'SwiftyGif', '~> 3.0.3'

    pod 'GoogleMaps', '= 2.1.0'
    pod 'GooglePlaces'
    pod 'GooglePlacePicker'
    
    pod 'PageMenu', :git => 'https://github.com/orazz/PageMenu.git' #View Pager
    pod 'IQKeyboardManagerSwift', '4.0.10'
    pod 'BadgeSwift', '~> 5.0' #Badge
    pod 'FCUUID', '~> 1.3.1'
    pod 'SwiftyStoreKit' #In-app purchase
    
    pod 'AppsFlyerFramework' #AppFlyer
    pod 'AppVersionMonitor', '~> 1.3.1'   
    pod 'SRMonthPicker', :git => 'https://github.com/AiryNo/SRMonthPicker.git', :branch => '0.2.11' #View Pager
    # Country Code Picker
    pod 'CountryPickerSwift'
    # Phone Number Validator
    pod 'libPhoneNumber-iOS'
    # Stripe Payment
    pod 'Stripe'
    pod 'Woopra-iOS'


    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        end
    end

end

