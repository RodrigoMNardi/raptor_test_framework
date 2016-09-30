$:.unshift "#{File.dirname(__FILE__)}"

require 'lib/factory/builder'

namespace :builder do
  task :test, [:name, :location] do |t, params|
    path = ''
    path += params[:location]
    path += '/'
    path += params[:name]
    path += '.rb'

    builder = Factory::Builder.new({test: path})
    builder.run
  end
end

