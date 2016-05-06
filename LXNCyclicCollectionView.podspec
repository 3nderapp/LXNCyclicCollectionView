Pod::Spec.new do |s|
  s.name                  = 'LXNCyclicCollectionView'
  s.version               = '0.1.0'
  s.summary               = 'This is the repository forLXNCyclicCollectionView.'
  s.homepage         	  = "https://github.com/3nderapp/LXNCyclicCollectionView"
  s.license          	  = 'MIT'
  s.author                = { 'Leszek Kaczor' => 'leszekducker@gmail.com' }
  s.source                = { :git => "https://github.com/3nderapp/LXNCyclicCollectionView.git", :tag => s.version.to_s }
  s.source_files          = 'LXNCyclicCollectionView/LXNCyclicCollectionView/*'
  s.requires_arc	      = true
  s.ios.deployment_target = '6.0'
end
