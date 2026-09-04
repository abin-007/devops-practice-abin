# ALB (Application Load Balancer)
 - path based routing
 - host based routing
 - ssl/tsl certificate(  aws certifiacte manager)

# VPC
# Public and private Ip 


# Security group
# ECS task deefinnition
# ECS task 
# ECR
# Faragate
- serverless engines to run the containers
# ECS services

# AWS  cloud formation template contains the following foormat
 - parameters which contains 
   ( ClusterName,SubnetIds, VpcIds, CPU,Memory, ImageUrl(dockerImage), ContainerPort, desiredCount)
- Resources(ECSCluster, LogGroup, ExecutionRole,           ALBSecurityGroup, SecurityGroup, LoadBalancer, TargetGroup,Listener,TaskDefinition, Service,)
- Outputs (ClusterName, ServiceName,TaskDefinitionArn,LoadBalancerDnsName )
