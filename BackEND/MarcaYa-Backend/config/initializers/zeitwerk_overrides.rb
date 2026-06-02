# frozen_string_literal: true

# Zeitwerk namespace overrides for Hexagonal Architecture directories.
#
# Rails 8.x auto-discovers all app/ subdirectories as Zeitwerk roots mapped to the
# top-level Object namespace. But our hexagonal directories use namespace wrappers:
#   app/domain/errors.rb       defines Domain::Errors       (not top-level Errors)
#   app/infrastructure/orm/    defines Infrastructure::Orm  (not top-level Orm)
#
# This override removes them from the main loader and re-registers them with
# the correct namespace mapping so Zeitwerk keeps lazy autoloading working.

main = Rails.autoloaders.main

# 1. Define namespace modules that the directories map to.
#    These MUST exist before push_dir(namespace:) is called.
module Domain; end unless Object.const_defined?(:Domain)
module Infrastructure; end unless Object.const_defined?(:Infrastructure)
module Ports; end unless Object.const_defined?(:Ports)
module Serializer; end unless Object.const_defined?(:Serializer)
module Application; end unless Object.const_defined?(:Application)

# 2. Map each directory to its namespace
NAMESPACE_MAP = {
  Domain.name         => Rails.root.join("app/domain"),
  Infrastructure.name => Rails.root.join("app/infrastructure"),
  Ports.name          => Rails.root.join("app/ports"),
  Serializer.name     => Rails.root.join("app/serializers"),
  Application.name    => Rails.root.join("app/application")
}.freeze

NAMESPACE_MAP.each do |ns_name, full_path|
  next unless File.directory?(full_path)

  # Remove from main loader so it doesn't interfere
  main.ignore(full_path.to_s)

  # Register with a dedicated loader that maps the directory to the right namespace
  loader = Zeitwerk::Loader.new
  loader.push_dir(full_path.to_s, namespace: Object.const_get(ns_name))
  loader.setup
end
