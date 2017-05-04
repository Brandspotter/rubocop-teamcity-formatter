# rubocop:disable Style/FileName

require 'rubocop'

module RuboCop
  module Formatter
    #
    class TeamCityFormatter < RuboCop::Formatter::BaseFormatter
      def started(_)
        @cops = Cop::Cop.all
        output.puts(teamcity_escape('testSuiteStarted name=\'Rubocop\''))
      end

      # rubocop:disable Metrics/AbcSize
      def file_finished(file, offences)
        @cops.each do |cop|
          offences.select { |off| off.cop_name == cop.cop_name }.each do |off|
            output.puts(teamcity_escape("testStarted name='#{file}'"))
            output.puts(
              teamcity_escape("testFailed name='#{file}' message=" \
                              "'#{off.location.to_s.gsub("#{Dir.pwd}/", '')}:" \
                              " #{off.message}'")
            )
            output.puts(teamcity_escape("testFinished name='#{file}'"))
          end
        end
      end

      def finished(_)
        output.puts(teamcity_escape('testSuiteFinished name=\'Rubocop\''))
      end

      private

      def teamcity_escape(message)
        "##teamcity[#{message.tr('\\', '|')}]"
      end
    end
  end
end
