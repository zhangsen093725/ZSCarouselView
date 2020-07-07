#
# Be sure to run `pod lib lint ZSCarouselView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZSCarouselView'
  s.version          = '0.1.0'
  s.summary          = '无限轮播'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  1. 跑马灯，cube 动画，可自定义 cube view
  2. 循环轮播，复用 Cell
  3. 可自定义Cell，水平、垂直滚动
  4. 可自定义FlowLayout
                       DESC

  s.homepage         = 'https://github.com/zhangsen093725/ZSCarouselView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  
  s.author           = { 'zhangsen093725' => 'joshzhang@yntengyun.com' }
  s.source           = { :git => 'https://github.com/zhangsen093725/ZSCarouselView.git', :tag => s.version.to_s }
  
  s.swift_version    = '5.0'
  s.ios.deployment_target = '8.0'

  s.source_files = 'ZSCarouselView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ZSCarouselView' => ['ZSCarouselView/Assets/*.png']
  # }

end
