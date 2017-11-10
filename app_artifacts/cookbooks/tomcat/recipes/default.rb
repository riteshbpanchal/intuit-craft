package "tomcat8" do
 action :install
end

service "tomcat8" do
 action [:enable, :start]
end
