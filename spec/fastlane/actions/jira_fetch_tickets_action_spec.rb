# frozen_string_literal: true

describe Fastlane::Actions::JiraFetchTicketsAction do
  describe '#run' do
    after do
      Fastlane::FastFile.new.parse('lane :test do
        Actions.lane_context[SharedValues::JIRA_FETCH_TICKETS_RESULT] = nil
      end').runner.execute(:test)
    end

    context 'without required variables raises an error' do
      it 'if url was not given' do
        expect do
          Fastlane::FastFile.new.parse("
        lane :test do
          jira_fetch_tickets(
            username: 'YOUR_USERNAME_HERE',
            password: 'YOUR_PASSWORD_HERE'
        )
        end").runner.execute(:test)
        end.to raise_error("No value found for 'url'")
      end

      it 'if username was not given' do
        expect do
          Fastlane::FastFile.new.parse("
        lane :test do
          jira_fetch_tickets(
            url: 'YOUR_URL_HERE',
            password: 'YOUR_PASSWORD_HERE'
        )
        end").runner.execute(:test)
        end.to raise_error("No value found for 'username'")
      end

      it 'if password was not given' do
        expect do
          Fastlane::FastFile.new.parse("
          lane :test do
            jira_fetch_tickets(
              url: 'YOUR_URL_HERE',
              username: 'YOUR_USERNAME_HERE'
          )
          end").runner.execute(:test)
        end.to raise_error("No value found for 'password'")
      end

      it 'if empty url was given' do
        expect do
          Fastlane::FastFile.new.parse("
          lane :test do
            jira_fetch_tickets(
              url: '',
              username: 'YOUR_USERNAME_HERE',
              password: 'YOUR_PASSWORD_HERE'
          )
          end").runner.execute(:test)
        end.to raise_error("No value found for 'url'")
      end

      it 'if empty username was given' do
        expect do
          Fastlane::FastFile.new.parse("
          lane :test do
            jira_fetch_tickets(
              url: 'YOUR_URL_HERE',
              username: '',
              password: 'YOUR_PASSWORD_HERE'
          )
          end").runner.execute(:test)
        end.to raise_error("No value found for 'username'")
      end

      it 'if empty password was given' do
        expect do
          Fastlane::FastFile.new.parse("
          lane :test do
            jira_fetch_tickets(
              url: 'YOUR_URL_HERE',
              username: 'YOUR_USERNAME_HERE',
              password: ''
          )
          end").runner.execute(:test)
        end.to raise_error("No value found for 'password'")
      end
    end

    context 'with variables given through invocation' do
      it 'succeeds with required variables' do
        stub_success_get('')

        response = Fastlane::FastFile.new.parse("
            lane :test do
            jira_fetch_tickets(
              url: 'https://jira-myCompany.atlassian.net',
              username: 'my_username',
              password: 'my_password'
          )
          end").runner.execute(:test)
        expect(response).to eq([{ issue: { 'key' => 'KEY-230' }, key: 'KEY-230' }])
      end

      it 'succeeds with all array variables' do
        stub_success_get('project%20in%20(project_one,%20project_two)%20AND%20status%20in%20(status_one,%20status_two)%20AND%20labels%20in%20(label_one,%20label_two)%20AND%20sprint%20in%20(sprint_one,%20sprint_two)%20AND%20my_custom_jql')

        response = Fastlane::FastFile.new.parse("
        lane :test do
          jira_fetch_tickets(
            url: 'https://jira-myCompany.atlassian.net',
            username: 'my_username',
            password: 'my_password',
            projects: ['project_one', 'project_two'],
            statuses: ['status_one', 'status_two'],
            labels: ['label_one', 'label_two'],
            sprints: ['sprint_one', 'sprint_two'],
            custom_jql: 'my_custom_jql'
        )
        end").runner.execute(:test)
        expect(response).to eq([{ issue: { 'key' => 'KEY-230' }, key: 'KEY-230' }])
      end

      it 'succeeds with all strings variables' do
        stub_success_get('project%20=%20my_project%20AND%20status%20=%20my_status%20AND%20labels%20=%20my_label%20AND%20sprint%20=%20my_sprint%20AND%20my_custom_jql')

        response = Fastlane::FastFile.new.parse("
        lane :test do
          jira_fetch_tickets(
            url: 'https://jira-myCompany.atlassian.net',
            username: 'my_username',
            password: 'my_password',
            project: 'my_project',
            status: 'my_status',
            label: 'my_label',
            sprint: 'my_sprint',
            custom_jql: 'my_custom_jql'
        )
        end").runner.execute(:test)
        expect(response).to eq([{ issue: { 'key' => 'KEY-230' }, key: 'KEY-230' }])
      end

      it 'fails' do
        sub_failed_get('')

        Fastlane::FastFile.new.parse("
        lane :test do
          jira_fetch_tickets(
            url: 'https://jira-myCompany.atlassian.net',
            username: 'my_username',
            password: 'my_password'
        )
        end").runner.execute(:test)
      rescue StandardError => e
        expect(e.message).to eq("undefined method `presence' for an instance of String")
      end
    end

    it 'supports ios' do
      expect(described_class.is_supported?(:ios)).to be(true)
    end

    it 'supports android' do
      expect(described_class.is_supported?(:android)).to be(true)
    end

    it 'supports mac' do
      expect(described_class.is_supported?(:mac)).to be(true)
    end

    it 'has correct description' do
      expect(described_class.description).to eq('Fetch ticekts on jira project using jql query')
    end

    it 'has correct details' do
      expect(described_class.details).to eq('Fetch ticekts on jira project using jql query')
    end

    it 'has correct authors' do
      expect(described_class.authors).to eq(['Luca Tagliabue'])
    end

    it 'has correct output' do
      expect(described_class.output).to eq([['JIRA_FETCH_TICKETS_RESULT', 'Hash object of key and issue.']])
    end

    it 'has correct return_value' do
      expect(described_class.return_value).to eq('Hash object of key and issue.')
    end
  end
end

# rubocop:disable Metrics/MethodLength
def stub_success_get(jql)
  url = "https://jira-mycompany.atlassian.net/rest/api/2/search?jql=#{jql}"

  stub_request(:get, url)
    .with(
      headers: {
        'Accept' => 'application/json',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Authorization' => 'Basic bXlfdXNlcm5hbWU6bXlfcGFzc3dvcmQ=',
        'User-Agent' => 'Ruby'
      }
    )
    .to_return(status: 200, body: '{"expand":"schema,names","startAt":0,"maxResults":50,"total":57290,"issues":[{"key":"KEY-230"}]}', headers: {})
end
# rubocop:enable Metrics/MethodLength

# rubocop:disable Metrics/MethodLength
def sub_failed_get(jql)
  url = "https://jira-mycompany.atlassian.net/rest/api/2/search?jql=#{jql}"

  stub_request(:get, url)
    .with(
      headers: {
        'Accept' => 'application/json',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Authorization' => 'Basic bXlfdXNlcm5hbWU6bXlfcGFzc3dvcmQ=',
        'User-Agent' => 'Ruby'
      }
    )
    .to_return(status: 401, body: '', headers: {})
end
# rubocop:enable Metrics/MethodLength
