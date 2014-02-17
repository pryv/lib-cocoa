## Test from command line

### OS X Example project
	xcodebuild -workspace PrYv-OSX-Example.xcworkspace test \
			   -scheme PrYv-OSX-Example -verbose \
			   -configuration Debug
	
### iOS Example project
	xcodebuild -workspace PrYv-iOS-Example.xcworkspace test \
				-scheme PrYv-iOS-Example -verbose \
				-configuration Debug \
				-sdk iphonesimulator7.0 \
				-destination 'platform=iOS Simulator,name=iPhone Retina (4-inch),OS=latest'