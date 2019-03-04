require 'gitlab'

# TODO: Move config to yaml
Gitlab.configure do |config|
  config.endpoint = ENV["GITLAB_HOST"] + '/api/v4'
  config.private_token = ENV["GITLAB_PERSONAL_ACCESS_TOKEN"]
end

def get_open_issues(group_path, state)
  my_group = Gitlab.groups(:search => group_path).find do |group|
    group.path == group_path
  end
  projects = Gitlab.group(my_group.id).projects.map do |proj|
    {:id => proj['id'], :name => proj['name']}
  end

  project_issues = Hash.new
  projects.each do |proj|
    project_issues[proj[:name]] = Gitlab.issues(proj[:id], :state => state).length
  end
  project_issues
end

SCHEDULER.every '5s', :first_in => 0 do |job|
  group_path = ENV["GITLAB_GROUP_PATH"]
  open_issues = get_open_issues(group_path, "opened")
  result = Array.new
  open_issues.each do |project, issue_num|
    result.push({value: issue_num, label: project})
  end
  result = result.sort_by {|result| result.zip}.reverse
  send_event('gitlab-open-issues', {items: result})
end