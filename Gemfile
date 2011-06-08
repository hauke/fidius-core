source 'http://rubygems.org'

require 'yaml'
YAML.load_file(File.expand_path('../config/fidius.yml', __FILE__))['databases'].each_pair{|env,conf|
  case conf['adapter']
  when /mysql/
    if RUBY_VERSION >= '1.9'
      gem 'mysql2', '~>0.2.6'
    else
      gem 'mysql' # or fail!?
    end
  when /postgresql/
    gem 'pg'
  when /sqlite3/
    gem 'sqlite3'
  else
    raise "Unknown database adapter #{conf['adapter']} for #{env} environment. Please send a bug report to grp-fidius@tzi.org."
  end
}

gem 'rake', '0.8.7'
gem 'rails', '~>3.0.6'
gem 'ai4r', '~>1.9'
gem 'algorithms', '~>0.3.0'
gem 'yard', '~>0.6.5'
gem 'fidius-common', '>= 0.0.4'
gem 'simplecov', '>= 0.4.0', :require => false, :group => :test
gem 'simplecov-rcov', '~> 0.2.0'
gem 'activesupport', '~>3.0.6'
gem 'amfranz-ci_reporter', '~>1.6.2'
gem 'test-unit', '~>2.3.0'
gem 'fidius-evasiondb', '>= 0.0.1'

