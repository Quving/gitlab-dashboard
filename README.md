# Smashing-Gitlab

[![Build Status](https://drone.quving.com/api/badges/Quving/gitlab-dashboard/status.svg)](https://drone.quving.com/Quving/gitlab-dashboard)

![](https://i.imgur.com/8h71zu1.png)

## Environment Variables
- ``` export GITLAB_HOST="https://gitlab.com" ```
    - That's your gitlab host.
- ``` export GITLAB_GROUP_NAME="curilab" ```
    - That's simply your group name of on gitlab.
- ``` export GITLAB_MILESTONE_PROJECT="hq" ```
    - Specify the project which milestones should be displayed.
- ``` export GITLAB_PERSONAL_ACCESS_TOKEN="yourtokenforgitlab" ```



## Installation

### Requirements
1. Ruby Version 2.5.1


### Steps
2. ``` git clone https://github.com/Quving/gitlab-dashboard.git```
3. ``` cd gitlab-dashboard ```
4. ``` gem install bundler ```
5. ``` bundle install ```
6. ``` smashing start ```
7. Visit http://localhost:3030 there should be something! :smiley: 



