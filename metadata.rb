maintainer       "ZeddWorks"
maintainer_email "scott.mcleod@zeddworks.com"
license          "Apache 2.0"
description      "Installs/Configures jenkins"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

%w{ java jks rvm }.each do |cb|
    depends cb
end

%w{ debian ubuntu centos redhat fedora }.each do |os|
    supports os
end
