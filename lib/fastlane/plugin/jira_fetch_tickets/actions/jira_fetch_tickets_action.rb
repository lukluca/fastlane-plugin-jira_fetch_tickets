# frozen_string_literal: true

require 'fastlane/action'
require 'fastlane_core'

module Fastlane
  module Actions
    module SharedValues
      JIRA_FETCH_TICKETS_RESULT = :JIRA_FETCH_TICKETS_RESULT
    end

    class JiraFetchTicketsAction < Action
      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/MethodLength
      def self.run(params)
        Actions.verify_gem!('jira-ruby')
        require 'jira-ruby'

        client = JIRA::Client.new(
          username: params[:username],
          password: params[:password],
          site: params[:url],
          context_path: '',
          auth_type: :basic
        )

        projects = params[:projects]
        project = params[:project]
        statuses = params[:statuses]
        status = params[:status]
        labels = params[:labels]
        label = params[:label]
        sprints = params[:sprints]
        sprint = params[:sprint]
        fix_versions = params[:fix_versions]
        fix_version = params[:fix_version]
        custom_jql = params[:custom_jql]

        jql = ''

        unless projects.instance_of?(NilClass)
          options = { key: 'project', values: projects }
          jql = jql_from_array?(options)
        end

        if jql.empty? && !project.instance_of?(NilClass)
          options = { key: 'project', value: project }
          jql = jql_from_string?(options)
        end

        added = false
        unless statuses.instance_of?(NilClass)
          options = { key: 'status', values: statuses, jql: jql }
          jql = append_jql_from_array?(options)
          added = true
        end

        if !added && !status.instance_of?(NilClass)
          options = { key: 'status', value: status, jql: jql }
          jql = append_jql_from_string?(options)
        end

        added = false
        unless labels.instance_of?(NilClass)
          options = { key: 'labels', values: labels, jql: jql }
          jql = append_jql_from_array?(options)
          added = true
        end

        if !added && !label.instance_of?(NilClass)
          options = { key: 'labels', value: label, jql: jql }
          jql = append_jql_from_string?(options)
        end

        added = false
        unless sprints.instance_of?(NilClass)
          options = { key: 'sprint', values: sprints, jql: jql }
          jql = append_jql_from_array?(options)
          added = true
        end

        if !added && !sprint.instance_of?(NilClass)
          options = { key: 'sprint', value: sprint, jql: jql }
          jql = append_jql_from_string?(options)
        end

        added = false
        unless fix_versions.instance_of?(NilClass)
          options = { key: 'fixversion', values: fix_versions, jql: jql }
          jql = append_jql_from_array?(options)
          added = true
        end

        if !added && !fix_version.instance_of?(NilClass)
          options = { key: 'fixversion', value: fix_version, jql: jql }
          jql = append_jql_from_string?(options)
        end

        if custom_jql
          options = { jql: jql, new_value: custom_jql }
          jql = append_jql?(options)
        end

        FastlaneCore::UI.message("JQL query is '#{jql}'")

        issues = client.Issue.jql(jql)

        issues = issues.map do |issue|
          { key: issue.key, issue: issue.attrs }
        end

        Actions.lane_context[SharedValues::JIRA_FETCH_TICKETS_RESULT] = issues

        FastlaneCore::UI.success('Successfully fetched JIRA tickets!')
        issues
      end

      def self.jql_from_array?(options)
        values = options[:values]
        values = values.map do |string|
          if string.should_escape
            "\"#{string}\""
          else
            string.to_s
          end
        end
        "#{options[:key]} in (#{values.join(', ')})"
      end

      def self.append_jql_from_array?(options)
        jql = options[:jql]
        options = { key: options[:key], values: options[:values] }
        to_append = jql_from_array?(options)
        options = { jql: jql, new_value: to_append }
        append_jql?(options)
      end

      def self.jql_from_string?(options)
        value = options[:value]
        if value.should_escape
          "#{options[:key]} = \"#{options[:value]}\""
        else
          "#{options[:key]} = #{options[:value]}"
        end
      end

      def self.append_jql_from_string?(options)
        jql = options[:jql]
        options = { key: options[:key], value: options[:value] }
        to_append = jql_from_string?(options)
        options = { jql: jql, new_value: to_append }
        append_jql?(options)
      end

      def self.append_jql?(options)
        jql = options[:jql]
        new_value = options[:new_value]

        if jql.empty?
          new_value
        else
          "#{jql} AND #{new_value}"
        end
      end
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/MethodLength

      def self.description
        'Fetch ticekts on jira project using jql query'
      end

      def self.authors
        ['Luca Tagliabue']
      end

      def self.return_value
        'Hash object of key and issue.'
      end

      def self.output
        [
          ['JIRA_FETCH_TICKETS_RESULT', 'Hash object of key and issue.']
        ]
      end

      def self.details
        'Fetch ticekts on jira project using jql query'
      end

      # rubocop:disable Metrics/MethodLength
      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :url,
                                       env_name: 'FL_JIRA_SITE',
                                       description: 'URL for Jira instance',
                                       sensitive: true,
                                       type: String,
                                       verify_block: ->(value) { verify_option(key: 'url', value: value) }),
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: 'FL_JIRA_USERNAME',
                                       description: 'Username for Jira instance',
                                       sensitive: true,
                                       type: String,
                                       verify_block: ->(value) { verify_option(key: 'username', value: value) }),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: 'FL_JIRA_PASSWORD',
                                       description: 'Password or api token for Jira',
                                       sensitive: true,
                                       type: String,
                                       verify_block: ->(value) { verify_option(key: 'password', value: value) }),
          FastlaneCore::ConfigItem.new(key: :projects,
                                       env_name: 'FL_JIRA_FETCH_JQL_PROJECTS',
                                       description: 'Array of Jira projects',
                                       type: Array,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :project,
                                       env_name: 'FL_JIRA_FETCH_JQL_PROJECT',
                                       description: 'Jira project',
                                       type: String,
                                       optional: true,
                                       conflicting_options: [:projects],
                                       conflict_block: proc do |_other|
                                                         FastlaneCore::UI.message('Ignoring :project in favor of :projects')
                                                       end),
          FastlaneCore::ConfigItem.new(key: :statuses,
                                       env_name: 'FL_JIRA_FETCH_JQL_STATUSES',
                                       description: 'Array of Jira status',
                                       type: Array,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :status,
                                       env_name: 'FL_JIRA_FETCH_JQL_STATUS',
                                       description: 'Jira status',
                                       type: String,
                                       optional: true,
                                       conflicting_options: [:statuses],
                                       conflict_block: proc do |_other|
                                                         FastlaneCore::UI.message('Ignoring :status in favor of :statuses')
                                                       end),
          FastlaneCore::ConfigItem.new(key: :labels,
                                       env_name: 'FL_JIRA_FETCH_JQL_LABELS',
                                       description: 'Array of Jira labels',
                                       type: Array,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :label,
                                       env_name: 'FL_JIRA_FETCH_JQL_LABEL',
                                       description: 'Jira label',
                                       type: String,
                                       optional: true,
                                       conflicting_options: [:labels],
                                       conflict_block: proc do |_other|
                                                         FastlaneCore::UI.message('Ignoring :label in favor of :labels')
                                                       end),
          FastlaneCore::ConfigItem.new(key: :sprints,
                                       env_name: 'FL_JIRA_FETCH_JQL_SPRINTS',
                                       description: 'Jira sprints',
                                       type: Array,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :sprint,
                                       env_name: 'FL_JIRA_FETCH_JQL_SPRINT',
                                       description: 'Jira sprint',
                                       type: String,
                                       optional: true,
                                       conflicting_options: [:sprints],
                                       conflict_block: proc do |_other|
                                                         FastlaneCore::UI.message('Ignoring :sprint in favor of :sprints')
                                                       end),
          FastlaneCore::ConfigItem.new(key: :fix_versions,
                                       env_name: 'FL_JIRA_FETCH_JQL_FIX_VERSIONS',
                                       description: 'Jira fix versions',
                                       type: Array,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :fix_version,
                                       env_name: 'FL_JIRA_FETCH_JQL_FIX_VERSION',
                                       description: 'Jira fix version',
                                       type: String,
                                       optional: true,
                                       conflicting_options: [:fix_versions],
                                       conflict_block: proc do |_other|
                                                         FastlaneCore::UI.message('Ignoring :fix_version in favor of :fix_versions')
                                                       end),
          FastlaneCore::ConfigItem.new(key: :custom_jql,
                                       env_name: 'FL_JIRA_FETCH_JQL_CUSTOM',
                                       description: 'Jira custom jql',
                                       type: String,
                                       optional: true)
        ]
      end
      # rubocop:enable Metrics/MethodLength

      def self.verify_option(options)
        FastlaneCore::UI.user_error!("No value found for '#{options[:key]}'") if options[:value].to_s.empty?
      end

      # rubocop:disable Metrics/MethodLength
      def self.example_code
        [
          'jira_fetch_tickets(
              url: "YOUR_URL_HERE",
              username: "YOUR_USERNAME_HERE",
              password: "YOUR_PASSWORD_HERE",
              project: "YOUR_PROJECT_HERE",
              status: "STATUS_HERE",
              label: "LABEL_HERE",
              sprint: "SPRINT_HERE",
              custom_jql: "CUSTOM_JQL_HERE"
          )'
        ]
      end
      # rubocop:enable Metrics/MethodLength

      def self.is_supported?(_platform)
        true
      end
    end
  end
end

class String
  def should_escape
    include?(' ') || include?('(') || include?(')')
  end
end
