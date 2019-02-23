#
# Cookbook:: s3cli
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

package "s3cmd" do
    action :install
end

#copy configuration file to user's home directory
node['s3cmd']['users'].each do |user|
    if user== 'root' 
        home = '/root'
    else 
        home = "/home/#{user}"
    end
    
    if File.exist? home
        file="#{home}/.s3cfg"
        template file do
            source 's3cli.erb'
            mode '0655'
        end
    else
        warn %Q(Home folder "#{home}" doesn't exist)
    end
    
end
