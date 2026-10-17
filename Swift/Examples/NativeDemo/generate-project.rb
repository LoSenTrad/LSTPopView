#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'xcodeproj'

# This generator only recreates the NativeSwiftDemo project beside this script.
# The checked-in project is immediately openable; regeneration is useful after
# adding a new App/**/*.swift scene. App sources and the legacy OC demo are never
# removed, copied, regenerated, or referenced by absolute machine-specific paths.
demo_root = File.expand_path(__dir__)
repo_root = File.expand_path('../../..', demo_root)
project_path = File.join(demo_root, 'NativeSwiftDemo.xcodeproj')
abort 'Run this generator inside the LSTPopView repository' unless File.file?(File.join(repo_root, 'Package.swift'))
abort 'NativeDemo App sources are missing' unless Dir.exist?(File.join(demo_root, 'App'))

FileUtils.rm_rf(project_path)
project = Xcodeproj::Project.new(project_path, false, 56)
project.root_object.attributes['LastUpgradeCheck'] = '2600'
project.root_object.compatibility_version = 'Xcode 14.0'
app = project.new_target(:application, 'NativeSwiftDemo', :ios, '15.0')

# Recursively reference App/**/*.swift in its real directory hierarchy. The root
# task can regenerate after parallel scene contributors finish; no fixed list of
# scene filenames needs to be synchronized by hand.
add_sources = lambda do |group, directory|
  Dir.children(directory).sort.each do |name|
    next if name.start_with?('.')

    path = File.join(directory, name)
    if File.directory?(path)
      add_sources.call(group.new_group(name, name), path)
    elsif File.extname(name) == '.swift'
      app.source_build_phase.add_file_reference(group.new_file(name))
    end
  end
end
add_sources.call(project.main_group.new_group('App', 'App'), File.join(demo_root, 'App'))

# Only this app target links the native library product, exactly once. Local
# package lookup is relative to the example folder and works in any clone path.
package = project.new(Xcodeproj::Project::Object::XCLocalSwiftPackageReference)
package.relative_path = '../../..'
project.root_object.package_references << package
product = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
product.package = package
product.product_name = 'LSTPopViewSwift'
app.package_product_dependencies << product
build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
build_file.product_ref = product
app.frameworks_build_phase.files << build_file

[project, app].each do |container|
  container.build_configurations.each do |configuration|
    settings = configuration.build_settings
    settings['SWIFT_VERSION'] = '6.0'
    settings['SWIFT_STRICT_CONCURRENCY'] = 'complete'
    settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    settings['CLANG_ENABLE_MODULES'] = 'YES'
    settings['CLANG_ENABLE_OBJC_ARC'] = 'YES'
    settings['TARGETED_DEVICE_FAMILY'] = '1,2'
    settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'YES'
  end
end

app.build_configurations.each do |configuration|
  settings = configuration.build_settings
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'org.lstpopview.examples.native'
  settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  settings['INFOPLIST_KEY_CFBundleDisplayName'] = 'Swift 弹窗示例'
  settings['INFOPLIST_KEY_UIApplicationSceneManifest_Generation'] = 'YES'
  settings['INFOPLIST_KEY_UILaunchScreen_Generation'] = 'YES'
  settings['INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents'] = 'YES'
  settings['INFOPLIST_KEY_LSRequiresIPhoneOS'] = 'YES'
  settings['CODE_SIGN_STYLE'] = 'Automatic'
end

scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(app)
scheme.set_launch_target(app)
scheme.launch_action.build_configuration = 'Debug'
scheme.save_as(project_path, 'NativeSwiftDemo', true)
project.save
puts "Generated #{project_path} with #{app.source_build_phase.files.count} Swift source references."
