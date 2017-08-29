$:.unshift File.dirname(__FILE__)

require 'lib/factory/configuration'
Factory::Configuration.instance._config_file_("#{File.dirname(__FILE__)}/configuration.yml")
require 'lib/factory/builder'

#
# EN:
# About execution mode - ONLINE AND OFFLINE.
#
# OFFLINE MODE
# In this mode, only a local user can request a test execution. AKA: non dedicated server
#
# ONLINE MODE
# Changes your PC in a tests server, accepting remote user's request.
#
# PT-BR:
# As diferenças entre os modos de operation - ONLINE E OFFLINE
#
# MODO OFFLINE
# Seria equivalente ao modo não dedicado para executar testes, somente o usuario local pode requisitar execução
#
# MODO ONLINE
# Torna o computador uma central de execuções de testes, onde usuários na rede possam solicitar execução de testes
#
#
namespace :builder do
  # EN: Run a single test - OFFLINE MODE
  # PT-BR: Executa somente um teste - MODO OFFLINE
  task :single_test, [:name] do |t, params|
    path = ''
    path += Factory::Configuration.instance.tests_path
    path += '/'
    path += params[:name]
    path += '.rb'

    builder = Factory::Builder.new({test: path, name: params[:name]})
    builder.run
  end

  # EN: Run multiples tests separately - OFFLINE MODE
  # PT-BR: Executa multiplos testes separadamente - OFFLINE MODE
  task :multiple_tests, [:names] do |t, params|
    params[:names].each do |name|
      path = ''
      path += Factory::Configuration.instance.tests_path
      path += '/'
      path += name
      path += '.rb'

      builder = Factory::Builder.new({test: path, name: params[:name]})
      builder.run
    end
  end
end

namespace :scheduler do
  task :run do
    puts 'TO BE IMPLEMENTED'
  end
end

