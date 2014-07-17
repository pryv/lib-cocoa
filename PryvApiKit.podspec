Pod::Spec.new do |s|
  s.name         = 'PryvApiKit'
  s.version      = '0.0.3'
  s.homepage     = 'https://github.com/pryv/sdk-objectivec-apple'
  s.summary      = 'PrYv SDK'
  s.authors      = { 'Pryv SA (Switzerland)' => 'http://pryv.com' }
  s.source       = { :git => 'https://github.com/pryv/sdk-objectivec-apple.git', :commit => '9d8f3d3c488ab25ba99903770ebb0807537ffc17' }
  s.license      = { :type => 'Revised BSD license', :file => 'LICENSE' }

  s.xcconfig     = { 'OTHER_LDFLAGS' => '-all_load' }
  
  # generally public headers should be clearly defined
  # but currently they keep us from running tests
  #s.public_header_files = 'Classes/PryvApiKit.h', 'Classes/PYError.h', 'Classes/PYConstants.h', 'Classes/PYErrorUtility.h', 'Classes/PYEvent.h', 'Classes/PYEvent+Utils.h', 'Classes/PYEventFilter.h', 'Classes/PYConnection.h', 'Classes/PYStream.h', 'Classes/PYAttachment.h', 'Classes/PYConnection+DataManagement.h', 'Classes/PYClient.h', 'Classes/PYWebLoginViewController.h', 'Classes/PYEventType.h', 'Classes/PYEventTypes.h', 'Classes/PYMeasurementSet.h'
  
  s.source_files = 'Classes/*.{h,m}'
  #s.exclude_files = 

  s.ios.deployment_target = "5.1"
  s.osx.deployment_target = "10.6"
  
  s.requires_arc = false
 
  s.subspec 'API' do |api|
  	api.source_files = 'Classes/API/*.{h,m}'
  	api.requires_arc = false
  	
  	api.subspec 'Cache' do |cache|
  		cache.source_files = 'Classes/API/Cache/*.{h,m}'
  		cache.requires_arc = false
  	end
  	
  	api.subspec 'Online' do |online|
  		online.source_files = 'Classes/API/Online/*.{h,m}'
  		online.requires_arc = false
  	end
  end
  
  s.subspec 'Authorization' do |auth|
  	auth.source_files = 'Classes/Authorization/*.{h,m}'
  	auth.requires_arc = false
  end
  
  s.subspec 'Filter' do |filter|
  	filter.source_files = 'Classes/Filter/*.{h,m}'
  	filter.requires_arc = false
  end
  
  s.subspec 'Model' do |model|
  	model.source_files = 'Classes/Model/*.{h,m}'
  	model.requires_arc = false
  	
  	model.subspec 'DataTypes' do |datatypes|
			datatypes.source_files = 'Classes/Model/DataTypes/*.{h,m}'
			datatypes.requires_arc = false
			
			datatypes.subspec 'Numerical' do |numerical|
				numerical.source_files = 'Classes/Model/DataTypes/Numerical/*.{h,m}'
				numerical.requires_arc = false
			end
			
		end
	
  end
  
  s.subspec 'Utils' do |utils|
  	utils.source_files = 'Classes/Utils/*.{h,m}'
  	utils.requires_arc = false
  	
  	utils.subspec 'Reachability' do |rsp|
			rsp.source_files = 'Classes/Utils/Reachability/*.{h,m}'
			rsp.requires_arc = false
  	end
  
		utils.subspec 'CWLSynthesizeSingleton' do |ssp|
			ssp.source_files = 'Classes/Utils/CWLSynthesizeSingleton/*.{h,m}'
			ssp.requires_arc = false
		end
  	
  end
  
  
  
end
