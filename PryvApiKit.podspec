Pod::Spec.new do |s|
  s.name         = 'PryvApiKit'
  s.version      = '0.0.2'
  s.homepage     = 'https://github.com/pryv/sdk-objectivec-apple'
  s.summary      = 'PrYv SDK'
  s.authors      = { 'Pryv SA (Switzerland)' => 'http://w.pryv.com' }
  s.source       = { :git => 'https://github.com/dkonst/sdk-objectivec-apple.git', :commit => 'a234f25e1cc10d4ec5e27c5e1a11c7a7e907d0a1' }
  s.license      = { :type => 'Revised BSD license', :file => 'LICENSE' }

  s.xcconfig     = { 'OTHER_LDFLAGS' => '-all_load' }
  
  # generally public headers should be clearly defined
  # but currently they keep us from running tests
  #s.public_header_files = 'Classes/PryvApiKit.h', 'Classes/PYError.h', 'Classes/PYConstants.h', 'Classes/PYErrorUtility.h', 'Classes/PYEvent.h', 'Classes/PYEvent+Utils.h', 'Classes/PYEventFilter.h', 'Classes/PYConnection.h', 'Classes/PYStream.h', 'Classes/PYAttachment.h', 'Classes/PYConnection+DataManagement.h', 'Classes/PYClient.h', 'Classes/PYWebLoginViewController.h', 'Classes/PYEventType.h', 'Classes/PYEventTypes.h', 'Classes/PYMeasurementSet.h'
  
  s.source_files = 'Classes/**/*.{h,m}'
  s.exclude_files = 'Classes/Reachability/PYReachability.{h,m}', 'Classes/CWLSynthesizeSingleton.h'

  s.ios.deployment_target = "5.1"
  s.osx.deployment_target = "10.6"
  
  s.requires_arc = false
  
  #s.dependency 'JSONKit'
  #s.dependency 'AnyJSON'
  #s.dependency 'CWLSynthesizeSingleton', '~> 0.0.2'
  #s.compiler_flags = '-Wno-deprecated-objc-isa-usage'
  
  s.subspec 'Reachability' do |rsp|
    rsp.source_files = 'Classes/Reachability/PYReachability.{h,m}'
    rsp.requires_arc = false
  end
  
  s.subspec 'CWLSynthesizeSingleton' do |ssp|
    ssp.source_files = 'Classes/CWLSynthesizeSingleton.{h,m}'
    ssp.requires_arc = false
  end
  
end
