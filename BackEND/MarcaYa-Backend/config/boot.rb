# Load environment variables from .env file if it exists
dot_env_file = File.expand_path("../.env", __dir__)
if File.exist?(dot_env_file)
  File.readlines(dot_env_file).each do |line|
    line = line.strip
    next if line.empty? || line.start_with?("#")
    key, value = line.split("=", 2)
    ENV[key.strip] = value.strip.gsub(/\A['"]|['"]\z/, "") if key && value
  end
end

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
