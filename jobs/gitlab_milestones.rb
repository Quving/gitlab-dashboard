require 'gitlab'

require 'gitlab'

# TODO: Move config to yaml
Gitlab.configure do |config|
  config.endpoint = ENV["GITLAB_HOST"] + '/api/v4'
  config.private_token = ENV["GITLAB_PERSONAL_ACCESS_TOKEN"]
end

def get_milestones(group_path, state, project_name)
  my_group = Gitlab.groups(:search => group_path).find do |group|
    group.path == group_path
  end
  projects = Gitlab.group(my_group.id).projects.map do |proj|
    {:id => proj['id'], :name => proj['name']}
  end

  project_milestones = projects.inject([]) {|merges, proj|
    Gitlab.milestones(proj[:id]).each do |milestone|
      milestone_issues = Gitlab.milestone_issues(proj[:id], milestone.id)
      opened_issues = milestone_issues.count {|x| x.state.eql? "opened"}
      closed_issues = milestone_issues.count {|x| x.state.eql? "closed"}
      progress = closed_issues > 0 ? 100 * closed_issues.to_f / opened_issues.to_f : 0
      merges.push({title: milestone.title,
                   description: milestone.description,
                   due_date: DateTime.parse(milestone.due_date).strftime("%b %-d %Y"),
                   opened_issues: opened_issues,
                   closed_issues: closed_issues,
                   progress: progress})
    end
    merges
  }
  project_milestones
end


SCHEDULER.every '5s', :first_in => 0 do |job|
  group_path = ENV["GITLAB_GROUP_NAME"]
  milestone_from_project = ENV["GITLAB_MILESTONE_PROJECT"]

  milestones = get_milestones(group_path, "opened", milestone_from_project)
  milestones = milestones.sort_by {|a| a[:due_date]}
  milestone = milestones.first
  if milestone.nil?
    milestone = {
        title: "No Milestones found",
        description: "Chuck Norris",
        due_date: "Mar 10 1942",
        progress: 42,
        opened_issues: 0,
        closed_issues: 0,
    }
  end
  send_event('gitlab-milestones', {
      milestone_title: milestone[:title][0, 12],
      milestone_description: milestone[:description],
      milestone_due_date: milestone[:due_date],
      milestone_progress: "%d %%" % [milestone[:progress]],
      milestone_opened_issues: milestone[:opened_issues],
      milestone_closed_issues: milestone[:closed_issues]
  })

end