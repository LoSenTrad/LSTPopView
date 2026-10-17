#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'xcodeproj'

fixture = File.expand_path(__dir__)
project_path = File.join(fixture, 'CoexistenceApp.xcodeproj')
repo_root = File.expand_path('../../..', fixture)
abort 'Run this fixture inside the LSTPopView repository' unless File.file?(File.join(repo_root, 'LSTPopView.podspec'))
abort 'The root Swift package must exist before generating the consumer' unless File.file?(File.join(repo_root, 'Package.swift'))

# This project is entirely generated and ignored by Git. Source files and the
# original OC example project are never deleted, regenerated or edited here.
FileUtils.rm_rf(project_path)
project = Xcodeproj::Project.new(project_path, false, 56)
project.root_object.attributes['LastUpgradeCheck'] = '1600'
project.root_object.compatibility_version = 'Xcode 14.0'

app = project.new_target(:application, 'CoexistenceApp', :ios, '16.0')
tests = project.new_target(:unit_test_bundle, 'CoexistenceTests', :ios, '16.0')
tests.add_dependency(app)

app_group = project.main_group.new_group('App', 'App')
Dir.glob(File.join(fixture, 'App', '*')).sort.each do |path|
  reference = app_group.new_file(File.basename(path))
  app.source_build_phase.add_file_reference(reference) if ['.swift', '.m'].include?(File.extname(path))
end
test_group = project.main_group.new_group('Tests', 'Tests')
Dir.glob(File.join(fixture, 'Tests', '*.swift')).sort.each do |path|
  tests.source_build_phase.add_file_reference(test_group.new_file(File.basename(path)))
end

# Run the package's actual native regression file in this scene-capable host.
# A file reference keeps one source of truth; it is not a copied test fixture.
native_tests = test_group.new_file('../../../Tests/LSTPopViewSwiftTests/LSTPopViewTests.swift')
tests.source_build_phase.add_file_reference(native_tests)

# Only the app links the native Swift product. Hosted tests import the app's
# helper; they do not produce another package image or duplicate class copy.
package = project.new(Xcodeproj::Project::Object::XCLocalSwiftPackageReference)
package.relative_path = '../../..'
project.root_object.package_references << package
product = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
product.package = package
product.product_name = 'LSTPopViewSwift'
app.package_product_dependencies << product
linked_product = project.new(Xcodeproj::Project::Object::PBXBuildFile)
linked_product.product_ref = product
app.frameworks_build_phase.files << linked_product

[project, app, tests].each do |container|
  container.build_configurations.each do |config|
    settings = config.build_settings
    settings['SWIFT_VERSION'] = '6.0'
    settings['SWIFT_STRICT_CONCURRENCY'] = 'complete'
    settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    settings['CLANG_ENABLE_MODULES'] = 'YES'
    settings['CLANG_ENABLE_OBJC_ARC'] = 'YES'
    settings['CODE_SIGNING_ALLOWED'] = 'NO'
    settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  end
end

app.build_configurations.each do |config|
  settings = config.build_settings
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'org.lstpopview.examples.coexistence'
  settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  settings['INFOPLIST_KEY_CFBundleDisplayName'] = 'OC + Swift Popups'
  settings['INFOPLIST_KEY_UIApplicationSceneManifest_Generation'] = 'YES'
  settings['INFOPLIST_KEY_UILaunchScreen_Generation'] = 'YES'
  settings['SWIFT_OBJC_BRIDGING_HEADER'] = '$(SRCROOT)/App/CoexistenceApp-Bridging-Header.h'
  settings['ENABLE_TESTABILITY'] = 'YES'
end
tests.build_configurations.each do |config|
  settings = config.build_settings
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'org.lstpopview.examples.coexistence.tests'
  settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/CoexistenceApp.app/CoexistenceApp'
  settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
  # The dependency app already built and linked this module. Find its Debug
  # .swiftmodule for @testable import, and resolve symbols from BUNDLE_LOADER.
  # Do not add the static package product to this target's Link Binary phase.
  settings['SWIFT_INCLUDE_PATHS'] = '$(inherited) $(BUILT_PRODUCTS_DIR)'
  settings['SWIFT_OBJC_BRIDGING_HEADER'] = '$(SRCROOT)/App/CoexistenceApp-Bridging-Header.h'
end

scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(app)
scheme.add_test_target(tests)
scheme.set_launch_target(app)
scheme.test_action.build_configuration = 'Debug'
scheme.test_action.should_use_launch_scheme_args_env = true
scheme.save_as(project_path, 'CoexistenceApp', true)
project.save
puts "Generated #{project_path}"
