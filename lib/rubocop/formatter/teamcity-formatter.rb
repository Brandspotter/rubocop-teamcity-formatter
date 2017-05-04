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
                              " #{replace_escaped_symbols(off.message)}'")
            )
            output.puts(teamcity_escape("testFinished name='#{file}'"))
          end
        end
      end

      def finished(_)
        output.puts(teamcity_escape('testSuiteFinished name=\'Rubocop\''))
      end

      private

      def replace_escaped_symbols(text)
        copy_of_text = String.new(text)
        copy_of_text.gsub!(/\|/, "||")
        copy_of_text.gsub!(/'/, "|'")
        copy_of_text.gsub!(/\n/, "|n")
        copy_of_text.gsub!(/\r/, "|r")
        copy_of_text.gsub!(/\]/, "|]")
        copy_of_text.gsub!(/\[/, "|[")
        begin
          copy_of_text.encode!('UTF-8') if copy_of_text.respond_to?(:encode!)
          copy_of_text.gsub!(/\u0085/, "|x") # next line
          copy_of_text.gsub!(/\u2028/, "|l") # line separator
          copy_of_text.gsub!(/\u2029/, "|p") # paragraph separator
        rescue
          # it is not an utf-8 compatible string
        end
        copy_of_text
      end

      def teamcity_escape(message)
        "##teamcity[#{message}]"
      end
    end
  end
end
