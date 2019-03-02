require 'gitlab'
require 'date'

# TODO: Move config to yaml
Gitlab.configure do |config|
  config.endpoint = ENV["GITLAB_HOST"] + '/api/v4'
  config.private_token = ENV["GITLAB_PERSONAL_ACCESS_TOKEN"]
end

def get_merge_requests(group_path, state)
  my_group = Gitlab.groups(:search => group_path).find do |group|
    group.path == group_path
  end
  projects = Gitlab.group(my_group.id).projects.map do |proj|
    {:id => proj['id'], :name => proj['name']}
  end

  open_merge_requests = projects.inject([]) {|merges, proj|
    Gitlab.merge_requests(proj[:id], :state => state).each do |request|
      merges.push({title: request.title,
                   repo: proj[:name],
                   updated_at: DateTime.parse(request.updated_at).strftime("%b %-d %Y, %l:%m %p"),
                   creator: "@" + request.author.username
                  })
    end
    merges
  }
  open_merge_requests
end

gmr_opened = 'gitlab-opened-merge-requests'
gmr_closed = 'gitlab-closed-merge-requests'

SCHEDULER.every '1m', :first_in => 0 do |job|
  project_name = ENV["GITLAB_GROUP_NAME"]
  open_merge_requests = get_merge_requests(project_name, "opened")
  send_event(gmr_opened, {header: "Open Merge Requests", merges: open_merge_requests.first(13)})

  project_name = ENV["GITLAB_GROUP_NAME"]
  closed_merge_requests = get_merge_requests(project_name, "closed")
  send_event(gmr_closed, {header: "Closed Merge Requests", merges: closed_merge_requests.first(13)})
end
