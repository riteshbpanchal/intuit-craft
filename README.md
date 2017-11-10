Via workstation

#bastion host connection (from local laptop)
ssh -i oregon_key.pem ec2-user@52.25.162.68

#to connect to workstation (from bastion host)
ssh -i oregon_key.pem ec2-user@10.0.6.11

#configure the Keys
[ec2-user@ip-10-0-6-11 ~]$ aws configure
AWS Access Key ID [None]:
AWS Secret Access Key [None]:
Default region name [None]: us-west-1
Default output format [None]:

#create S3 bucket
[ec2-user@ip-10-0-6-11 ~]$ aws s3 mb s3://craft-demo-intuit-1
make_bucket: craft-demo-intuit-1

[ec2-user@ip-10-0-6-11 ~]$ aws s3 ls
2017-11-04 11:17:49 auth-key-bucket-a
2017-11-03 07:57:19 cf-templates-1arqimfv9z5cx-us-east-1
2017-11-04 06:06:41 cf-templates-1arqimfv9z5cx-us-west-1
2017-11-04 11:09:28 cf-templates-1arqimfv9z5cx-us-west-2
2017-11-04 14:09:54 craft-demo-intuit
2017-11-04 17:04:58 craft-demo-intuit-1



#create web artifact and upload on S3 bucket

[ec2-user@ip-10-0-6-11 ~]$ aws s3 cp web_chef.tar.gz s3://craft-demo-intuit-1
upload: ./web_chef.tar.gz to s3://craft-demo-intuit-1/web_chef.tar.gz

#Web server userdata:

yum install https://packages.chef.io/files/stable/chefdk/1.3.43/el/7/chefdk-1.3.43-1.el7.x86_64.rpm -y
aws s3 cp s3://craft-demo-intuit-1/web_chef.tar.gz /home/ec2-user
tar xvf /home/ec2-user/web_chef.tar.gz -C /var
chef-solo -j /var/chef/cookbooks/httpd/run.json

#create App artifact and upload on S3 bucket
 
[ec2-user@ip-10-0-6-11 ~]$ aws s3 cp app_chef.tar.gz s3://craft-demo-intuit-1/
upload: ./app_chef.tar.gz to s3://craft-demo-intuit-1/app_chef.tar.gz

App tier userdata:
yum install https://packages.chef.io/files/stable/chefdk/1.3.43/el/7/chefdk-1.3.43-1.el7.x86_64.rpm -y
aws s3 cp s3://craft-demo-intuit-1/app_chef.tar.gz /home/ec2-user
tar xvf /home/ec2-user/app_chef.tar.gz -C /var
chef-solo -j /var/chef/cookbooks/tomcat/run.json


#execute CF stack via AWS CLI
export AWS_DEFAULT_REGION=us-west-1

KEY_NAME=craft_n_california
INSTACE_TYPE=t2.micro

aws cloudformation create-stack  --stack-name tierapp1  --template-body file://craft.yml   --parameters  ParameterKey=myKeyPair,ParameterValue=$KEY_NAME ParameterKey=InstanceTypeParameter,ParameterValue=$INSTACE_TYPE --capabilities CAPABILITY_IAM

aws cloudformation describe-stacks --stack-name tierapp1

