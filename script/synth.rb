#!/usr/bin/env ruby

require "fileutils"

DIR = File.dirname __dir__

def execute cmd
  puts cmd
  abort unless system cmd
end

# In an autosynth (multi-library) run, a previous library synth may have
# created a new library. If so, autosynth doesn't clean up those newly created
# files (i.e. it runs git reset --hard but not git clean). Do that ourselves,
# so any previously created files don't pollute this and subsequent synth runs.
execute "git clean -df"

Dir.chdir "google-apis-generator"

execute "bundle install"

if ARGV.empty?
  execute "echo a | bundle exec bin/generate-api gen #{DIR}/generated --from-discovery --no-preferred-only --names=#{DIR}/api_names.yaml --names-out=#{DIR}/api_names_out.yaml --spot-check"
elsif ARGV == ["--clean"] || ARGV == ["clean"]
  execute "bundle exec bin/generate-api gen #{DIR}/generated --clean"
elsif ARGV.size == 2
  api, version = ARGV
  execute "echo a | bundle exec bin/generate-api gen #{DIR}/generated --api=#{api}.#{version} --names=#{DIR}/api_names.yaml --names-out=#{DIR}/api_names_out.yaml --spot-check"
else
  abort "Bad arguments: #{ARGV}"
end
