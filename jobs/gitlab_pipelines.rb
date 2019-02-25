require 'net/http'
require 'uri'
require 'json'


# TODO: Move config to yaml
Gitlab.configure do |config|
  config.endpoint = ENV["GITLAB_HOST"] + '/api/v4'
  config.private_token = ENV["GITLAB_PERSONAL_ACCESS_TOKEN"]
end

def get_pipelines(group_path, state)
  my_group = Gitlab.groups(:search => group_path).find do |group|
    group.path == group_path
  end
  projects = Gitlab.group(my_group.id).projects.map do |proj|
    {:id => proj['id'], :name => proj['name']}
  end

  group_pipelines = projects.inject([]) {|pipelines, proj|
    Gitlab.pipelines(proj[:id], :status => state).each do |pipeline|
      pipeline_detailed = Gitlab.pipeline(proj[:id], pipeline.id).to_h
      pipeline_jobs = Gitlab.pipeline_jobs(proj[:id], pipeline.id, :status => state)
      pipeline_detailed["repo"] = proj[:name]
      pipeline_detailed["jobs"] = pipeline_jobs
      pipelines.push(pipeline_detailed)
    end
    pipelines
  }
  group_pipelines
end

SCHEDULER.every '10s', :first_in => 0 do
  project_name = ENV["GITLAB_GROUP_NAME"]
  group_pipelines = get_pipelines(project_name, "running")

  display = Hash.new({value: 0})
  group_pipelines.each do |pipeline|

    # Set label
    label = "%s (%s)" % [pipeline["repo"], pipeline["ref"]]
    threshold = 45
    if label.length >= threshold
      label = label[0, threshold - 2] + "..."
    end

    # Value
    value = "unknown stage"
    pipeline["jobs"].each do |job|
      if job.status.eql? "running"
        time = Time.at(job.duration.to_i).utc.strftime("%M:%S")
        value = "%s | %s" % [job.stage, time]
      end
    end

    # Url
    url = pipeline["user"]["avatar_url"]
    display[Time.now] = {label: label, value: value, url: url}
  end
  send_event('gitlab-pipelines', {header: "Running Pipelines", items: display.values})
end
