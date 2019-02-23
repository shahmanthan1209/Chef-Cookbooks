#
# Cookbook:: tomcat
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

#create group and user tomcat 
=begin
group 'tomcat' do
    group_name 'tomcat'
end

user 'tomcat' do 
    group 'tomcat'
    home '/opt/tomcat'
    shell '/bin/false'
end
=end
temp_path = Chef::Config[:file_cache_path]

remote_file "#{temp_path}/apache-tomcat-8*.zip" do
    source node['tomcat']['download_url']
    #group 'tomcat'
    #owner node['tomcat']['tomcat_user']
    mode '0644'
    action :create
end

directory node['tomcat']['install_location'] do
    #group 'tomcat'
    #owner node['tomcat']['tomcat_user']
    mode '0755'
    not_if { ::Dir.exist?(node['tomcat']['install_location'])}
    action :create
end
    

#install unzip package which will be used to extract tomcat.zip
package "unzip" do
    action :install
end

#execute "tar xzvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1"
#execute "unzip apache-tomcat-8*.zip -d /opt/tomcat"
bash 'extract package' do
    cwd node['tomcat']['install_location']
    #user node['tomcat']['tomcat_user']
    code <<-EOH
    unzip #{temp_path}/apache-tomcat-8*.zip 
    EOH
    ignore_failure true
    action :run
end

execute 'move' do
    cwd node['tomcat']['install_location']
    command "sudo mv -f apache-tomcat-8*/* ." #shows error when already exist some dir
    #not_if { ::Dir.exist?(node['tomcat']['install_location']/bin)}
    ignore_failure true
end

execute 'add_execute_bin' do
    command 'chmod -R +x /opt/tomcat/bin'
end     

#Install init script
template "/etc/systemd/system/tomcat.service" do
    source 'tomcat.erb'
    owner 'root'
    mode '0755'
end
=begin
#edit tomcat-users.xml
template "/opt/tomcat/conf/tomcat-users.xml" do
    source "users.erb"
    mode '0644'
    notifies :restart, "service[tomcat8]"
end
=end
cookbook_file '/opt/tomcat/conf/tomcat-users.xml' do
  source 'tomcat-users.xml'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

#edit context.xml
=begin
execute "mv /opt/tomcat/webapps/manager/META-INF/context.xml /opt/tomcat/webapps/manager/META-INF/context.xml.bak"
template "/opt/tomcat/webapps/manager/META-INF/context.xml" do
    source "context.erb"
    mode '0644'
    notifies :restart, "service[tomcat8]"
end
=end
cookbook_file '/opt/tomcat/webapps/manager/META-INF/context.xml' do
  source 'context.xml'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end
execute "start_tomcat" do
  cwd node['tomcat']['install_location']	
  command 'sudo sh bin/startup.sh'
end
=begin
#Start and enable tomcat service if requested
service 'tomcat' do
    action [:enable, :start]
    only_if { node['tomcat']['autostart'] }
  end 
=end 
# sudo chmod +x /opt/tomcat/bin/*
#TO START AND STOP RUN FILES FROM /opt/tomcat/bin
