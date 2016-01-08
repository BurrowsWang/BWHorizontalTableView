Pod::Spec.new do |s|
  s.name         	= "BWHorizontalTableView"
  s.version      	= "1.0.1"
  s.summary      	= "BWHorizontalTableView is an efficient horizontal table view based on Objective-c with same usage and interface as UITableView."
  s.homepage     	= "https://github.com/BurrowsWang/BWHorizontalTableView"
  s.license      	= { :type => 'MIT' }
  s.author       	= { "BurrowsWang" => "burrowswang@gmail.com" }
  s.platform     	= :ios, "7.0"
  s.source       	= { :git => "https://github.com/BurrowsWang/BWHorizontalTableView.git", :tag => s.version.to_s }
  s.source_files = 'BWHorizontalTableView/*.{h,m,c}'
  s.requires_arc 	= true
  
end
