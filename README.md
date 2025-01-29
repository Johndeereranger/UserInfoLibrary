# UserInfoLibrary

Product Market Fit Implimentation:

struct MyAppPMFConfiguration: PMFConfiguration {
    static var productMarketFitImage: Image {
        return Image("Crabtree") // Replace with your image name
    }
}


if Swift UI in side of 
struct MyApp: App {
    init() {
        PMFConfigurationProvider.configuration = MyAppPMFConfiguration.self
    }
    
    
If UIKIT:
 func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Register the PMF Configuration
        PMFConfigurationProvider.configuration = MyAppPMFConfiguration.self

        return true
    }
