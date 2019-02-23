#
# Cookbook:: java8
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

# Install Package

package "default-jre" do
    action :install
end

package "default-jdk" do
    action :install
end

execute "add-apt-repository ppa:webupd8team/java" 
#Run apt-get update
#action :execute do
    include_recipe 'java8::apt'
#end

#package "oracle-java8-installer" do
#    action :install
#end

execute "wget --continue --no-check-certificate --header \"Cookie: oraclelicense=a\" 'http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/jdk-8u161-linux-x64.tar.gz'"
execute "tar -xf jdk-8u161-linux-x64.tar.gz"

execute "mkdir –p /usr/lib/jvm/java-8-oracle" do
ignore_failure true
end
execute "mv jdk1.8.0_161/*  /usr/lib/jvm/java-8-oracle/." do
ignore_failure true
end
execute "sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-8-oracle/jre/bin/java 1091"

execute "sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-8-oracle/bin/javac 1091"


execute "update-alternatives --config java" 
