require 'bundler/gem_tasks'

require "rspec/core/rake_task"

Dir["./tasks/*.rb"].sort.each &method(:require)





RSpec::Core::RakeTask.new(:spec)

task :default => :spec

require "bundler/gem_tasks"

Rake::Task["release:rubygem_push"].clear
Rake::Task["release"].clear

task release: %w[
  build
  release:packagecloud_check
  release:guard_clean
  release:source_control_push
  release:packagecloud_push
]

task "release:packagecloud_check" do
  cmd = "package_cloud repository list"

  # next if Bundler.unbundled_system("#{cmd} < /dev/null > /dev/null 2>&1")

  Bundler.ui.error <<~ERRMSG
    You need to be logged in via Packagecloud CLI util in order to release.
    Please run something like
      $ #{cmd}
    ...and make sure it returns without an error before continuing.
  ERRMSG

  Bundler.ui.confirm("done")
  exit 1
end

task "release:packagecloud_push" do
  spec = Bundler.load_gemspec_uncached(File.expand_path(Dir["*.gemspec"].first))
  name = spec.name
  version = spec.version
  pkg_file = "pkg/#{name}-#{version}.gem"
  pkg_file = File.expand_path(pkg_file)

  unless File.exist?(pkg_file)
    Bundler.ui.error <<~ERRMSG
      Could not find built gem file to release.
      Expected a file to be available at: #{pkg_file}
    ERRMSG

    exit 1
  end

  cmd = "package_cloud push heroku/gemgate #{pkg_file}"

  if Bundler.unbundled_system("#{cmd} > /dev/null")
    Bundler.ui.confirm("Pushed #{name} #{version} to Packagecloud")
  else
    Bundler.ui.error <<~ERRMSG
      Failed to push the gem to Packagecloud. Try doing it manually:
        #{cmd}
    ERRMSG

    exit 1
  end
end