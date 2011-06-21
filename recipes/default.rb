#
# Cookbook Name:: jenkins
# Recipe:: default
#
# Copyright 2011, ZeddWorks
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "java"

case node[:platform]
when "redhat"
  execute "Install Jenkins rpm from URL" do
    command "rpm -Uhv http://mirrors.jenkins-ci.org/redhat/jenkins-1.415-1.1.noarch.rpm"
    not_if "rpm -q jenkins"
    action :run
  end
  execute "Upgrade Jenkins" do
    command "yum upgrade"
    action :run
  end
when "debian"
  execute "Install Jenkins deb from URL" do
    command "(wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -); echo 'deb http://pkg.jenkins-ci.org/debian binary/' > /etc/apt/sources.list.d/jenkins.list; aptitude update; aptitude -y install jenkins"
    not_if "dpkg-query -s jenkins"
  end
end

jenkins = Chef::EncryptedDataBagItem.load("apps", "jenkins")
ca = Chef::EncryptedDataBagItem.load("apps", "ca")

jks_keystore jenkins["ca_subject"] do
  ca_url ca["ca_url"]
  ca_user ca["ca_user"]
  ca_pass ca["ca_pass"]
  store_pass ca["store_pass"]
  user_agent ca["user_agent"]
  jks_path jenkins["jks_path"]
end

template "/etc/sysconfig/jenkins" do
  source "jenkins.erb"
  variables ({
    :httpsPort => jenkins["httpsPort"],
    :jks_path => jenkins["jks_path"],
    :store_pass => jenkins["store_pass"]
  })
  notifies :restart, "service[jenkins]"
end

service "jenkins" do
  supports :restart => true, :reload => true, :status => true
  action [ :enable, :start ]
end
