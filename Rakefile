$:.unshift File.dirname(__FILE__)

require 'lib/factory/configuration'
Factory::Configuration.instance._config_file_("#{File.dirname(__FILE__)}/configuration.yml")
require 'lib/factory/builder'

namespace :builder do
  task :test, [:name, :location] do |t, params|
    path = ''
    path += params[:location]
    path += '/'
    path += params[:name]
    path += '.rb'

    builder = Factory::Builder.new({test: path, name: params[:name]})
    builder.run
  end
end

