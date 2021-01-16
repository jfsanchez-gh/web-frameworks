# frozen_string_literal: true

require 'git'

namespace :ci do
  task :matrix do
    base = ENV['BASE_COMMIT']
    last = ENV['LAST_COMMIT']
    frameworks = []

    files = []

    workdir = ENV.fetch('GITHUB_WORKSPACE') { Dir.pwd }
    warn "Checking for modification from #{base} to #{last}"
    git = Git.open(Dir.pwd)

    diff = git.gtree(last).diff(base).each { |diff| files << diff.path }
    warn "Detected modified files - #{files.join(',')}"

    files.each do |file|
      if file.match(File::SEPARATOR) && !file.start_with?('.')
        parts = file.split(File::SEPARATOR)
        if file.end_with?("Dockerfile")
          language, _ = file.split(File::SEPARATOR)
          
          Dir.glob("#{language}/*/config.yaml").each do |path|
            subs = path.split(File::SEPARATOR)
            frameworks << subs[0..1].join(File::SEPARATOR)
          end
        else
        frameworks << parts[0..1].join(File::SEPARATOR)
        end
      end
      
      
    end

    matrix = { include: [] }
    frameworks.uniq.each do |framework|
      matrix[:include] << { directory: framework, framework: framework }
    end

    puts matrix.to_json
  end
end
