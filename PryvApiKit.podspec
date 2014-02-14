Pod::Spec.new do |s|
  s.name         = 'PryvApiKit'
  s.version      = '0.0.1'
  s.homepage     = 'https://github.com/pryv/sdk-objectivec-apple'
  s.summary      = 'A DeLorean helps you test your time-dependent code allowing you travel anywhere in time.'
  s.authors      = { 'Pryv SA (Switzerland)' => 'http://w.pryv.com' }
  s.source       = { :git => 'https://github.com/pryv/sdk-objectivec-apple.git', :commit => '72eb3379e1367' }
  s.source_files = 'Classes/**/*.{h,m}'
  s.license      = { :type => 'Revised BSD license', :file => 'LICENSE' }
  s.requires_arc = false
end
