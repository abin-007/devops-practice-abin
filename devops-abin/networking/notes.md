## SUBNET, IPADDRESS, Net

Think of AWS networking as building a secure office campus. Your VPC is the campus boundary, subnets are separate buildings or zones inside it, route tables are the road signs, security groups are door security, and internet/NAT gateways are controlled entrances to the outside world.

1. Start with the basic concept: What is an IP address?

Every device that communicates over an IP network needs an IP address.

Example:

10.0.1.25
An IPv4 address contains 32 bits and normally appears as four numbers:

10 . 0 . 1 . 25
Each part can range from 0 to 255.

In AWS, EC2 instances, ECS tasks, load balancers, databases, NAT gateways, and other network-connected resources may receive IP addresses.

There are two important categories:

Private IP address
Public IP address
Private IP

A private IP works inside private networks.

Typical private address ranges are:

10.0.0.0 - 10.255.255.255

172.16.0.0 - 172.31.255.255

192.168.0.0 - 192.168.255.255
Example:

10.0.2.34
That address normally cannot be reached directly from the public Internet.

This is what you usually want for application servers, ECS tasks, databases, internal services, etc.

Public IP

A public IP can be routed over the Internet.

Example:

3.121.45.72
If an EC2 instance has a public IP and the surrounding AWS networking/security configuration allows it, somebody on the Internet can potentially reach it.

That does not mean a public IP automatically makes something accessible. Route tables, Internet Gateway, Security Groups, NACLs and the application itself still matter.

2. What is a network?

Suppose your company owns this IP range:

10.0.0.0/16
This does not represent one server.

It represents an entire network.

The /16 is called the CIDR prefix.

CIDR means:

Classless Inter-Domain Routing
The /16 tells us how much of the IP address identifies the network.

For:

10.0.0.0/16
the first 16 bits belong to the network.

In practical terms, the address range is approximately:

10.0.0.0
to
10.0.255.255
That gives:

65,536 IP addresses
You can then divide this big network into smaller networks.

Those smaller networks are called subnets.

3. What is a subnet?

A subnet is simply a smaller IP network carved out of a larger network.

Imagine your VPC has:

10.0.0.0/16
You could create:

10.0.1.0/24
10.0.2.0/24
10.0.11.0/24
10.0.12.0/24
Each /24 contains 256 IP addresses.

For example:

10.0.1.0/24
covers:

10.0.1.0
through
10.0.1.255
AWS reserves five addresses in each subnet, so not all 256 are usable.

For example, AWS reserves addresses such as network, router, DNS-related and broadcast-reserved addresses.

Therefore:

/24 = 256 total addresses
      251 usable in AWS
4. Common CIDR sizes you should know

As a DevOps engineer, you should become comfortable with this table:

CIDR	Total IPs	Typical use
/16	65,536	Large VPC
/20	4,096	Medium network
/22	1,024	Large subnet
/24	256	Very common subnet
/25	128	Small subnet
/26	64	Smaller subnet
/27	32	Very small subnet
/28	16	Minimum practical AWS subnet size
For example:

10.0.0.0/16
could be divided into:

10.0.1.0/24
10.0.2.0/24
10.0.3.0/24
...
A common beginner mistake is creating very small subnets.

For ECS Fargate especially, every task usually gets its own private IP address.

If you create:

10.0.1.0/28
you only have 16 addresses total and 11 usable in AWS.

That can become a problem very quickly.

5. AWS VPC

A VPC — Virtual Private Cloud is your private network inside AWS.

Example:

VPC
CIDR: 10.0.0.0/16
You can think of it as:

AWS Account

        Internet
           |
     +-------------+
     |    VPC      |
     | 10.0.0.0/16 |
     |             |
     | Subnets     |
     | Servers     |
     | Databases   |
     | ECS Tasks   |
     +-------------+
Resources inside the same VPC can normally communicate using private IP addresses, assuming routing and security rules permit it.

6. What exactly is a subnet in AWS?

In AWS, a subnet has two important properties:

1. It has a CIDR range
2. It belongs to exactly one Availability Zone
Suppose your AWS region is Frankfurt:

eu-central-1
You might have:

eu-central-1a
eu-central-1b
eu-central-1c
You cannot create one subnet spanning multiple AZs.

For example:

VPC 10.0.0.0/16

eu-central-1a
    10.0.1.0/24

eu-central-1b
    10.0.2.0/24
This is important for high availability.

7. Public subnet vs private subnet

This is one of the most misunderstood AWS concepts.

A subnet is not public because its name says "public."

A subnet is public because its routing allows direct communication with an Internet Gateway.

The key difference is usually the route table.

8. Public subnet

Suppose we create:

PublicSubnetA
10.0.1.0/24
Its route table might contain:

Destination        Target

10.0.0.0/16        local
0.0.0.0/0          Internet Gateway
The important route is:

0.0.0.0/0 -> Internet Gateway
0.0.0.0/0 basically means:

Everything that is not otherwise matched.

Therefore:

Internet traffic
        ↓
Internet Gateway
        ↓
Public Subnet
Resources in that subnet can potentially communicate directly with the Internet if they also have a public IP.

9. Internet Gateway

An Internet Gateway, usually abbreviated IGW, connects a VPC to the Internet.

Architecture:

Internet
   |
   |
Internet Gateway
   |
   |
VPC
A VPC can have an Internet Gateway attached.

Example:

VPC: 10.0.0.0/16

Internet Gateway:
igw-12345678
Then your public subnet's route table might contain:

0.0.0.0/0 -> igw-12345678
Without this route, the subnet is not public.

10. Important: Public subnet does not mean every resource is public

Suppose you have an EC2 instance:

Private IP:
10.0.1.25
inside a public subnet.

If the EC2 instance has:

No public IPv4 address
it usually cannot be reached directly from the Internet.

For direct Internet communication you usually need:

Public subnet
+
Internet Gateway route
+
Public IP
+
Security Group rule
All these pieces matter.

11. Private subnet

Now consider:

PrivateSubnetA
10.0.11.0/24
Its route table does not contain:

0.0.0.0/0 -> Internet Gateway
Therefore resources cannot directly access the Internet through an IGW.

For example:

Internet

   X
   |
Private subnet
10.0.11.0/24
This is where we normally place:

ECS application tasks
Application servers
Databases
Internal services
Worker processes
12. But private servers still need Internet access

A common question from junior engineers is:

If an ECS task is in a private subnet, how does it download its Docker image from ECR?

Excellent question.

Private resources frequently need outbound Internet/AWS service access.

For example they may need to:

pull container images
download packages
call APIs
install updates
contact external services
But we usually don't want Internet users connecting directly to them.

That is where a NAT Gateway comes in.

13. NAT Gateway

NAT means:

Network Address Translation
Architecture:

Private ECS Task
10.0.11.25
      |
      |
Private Route Table
      |
      |
NAT Gateway
      |
      |
Internet Gateway
      |
      |
Internet
The ECS task can initiate an outbound connection.

For example:

ECS task
   ↓
NAT Gateway
   ↓
Internet
But an Internet user normally cannot initiate a connection like:

Internet
   ↓
NAT Gateway
   ↓
ECS Task
That does not work like normal inbound routing.

This makes private subnets significantly safer for application workloads.

14. Where does the NAT Gateway live?

Very important AWS interview and architecture question:

A NAT Gateway is normally placed inside a public subnet.

Why?

Because the NAT Gateway itself needs Internet access.

For example:

VPC
│
├── PublicSubnetA
│      │
│      ├── ALB
│      │
│      └── NAT Gateway
│              │
│              └── Internet Gateway
│
└── PrivateSubnetA
       │
       ├── ECS Task
       ├── ECS Task
       └── Application Server
The private subnet routes Internet traffic toward the NAT Gateway:

0.0.0.0/0 -> NAT Gateway
The public subnet routes Internet traffic toward the Internet Gateway:

0.0.0.0/0 -> Internet Gateway
15. Route tables

A route table tells AWS:

When traffic is going toward this destination, send it to this target.

Example public route table:

Destination       Target

10.0.0.0/16       local
0.0.0.0/0         igw-12345
Meaning:

Traffic for 10.0.x.x:
stay inside the VPC

Everything else:
send to Internet Gateway
Example private route table:

Destination       Target

10.0.0.0/16       local
0.0.0.0/0         nat-12345
Meaning:

Traffic for 10.0.x.x:
stay inside the VPC

Internet traffic:
send to NAT Gateway
16. The "local" route

When AWS creates the VPC route table, you will see something similar to:

10.0.0.0/16 -> local
Do not remove or overthink this.

It means:

resources inside this VPC can route to each other
For example:

ECS Task
10.0.11.20

can communicate with

RDS
10.0.21.40
assuming Security Groups and NACLs permit it.

17. Typical production AWS layout

For a production application I would commonly start with:

VPC
10.0.0.0/16
Then create subnets across at least two Availability Zones.

Example:

             VPC 10.0.0.0/16

         Availability Zone A
         -------------------

PublicSubnetA
10.0.1.0/24

PrivateAppSubnetA
10.0.11.0/24

PrivateDBSubnetA
10.0.21.0/24


         Availability Zone B
         -------------------

PublicSubnetB
10.0.2.0/24

PrivateAppSubnetB
10.0.12.0/24

PrivateDBSubnetB
10.0.22.0/24
This is a very common pattern.

18. What goes into each subnet?

Public subnets

Typically:

Application Load Balancer
NAT Gateway
possibly bastion hosts
You normally should not place databases or sensitive backend services here.

Private application subnets

Typically:

ECS Fargate tasks
EC2 application servers
microservices
workers
internal APIs
Private database subnets

Typically:

RDS
Aurora
ElastiCache
Often database subnets don't even need NAT Internet access.

19. Your ECS Fargate architecture

Since you're working on ECS Fargate for ePG, I would recommend something like this:

                         Internet
                             |
                             |
                      Internet Gateway
                             |
                             |
                  +----------------------+
                  |                      |
             PublicSubnetA          PublicSubnetB
             10.0.1.0/24            10.0.2.0/24
                  |                      |
                  +----------+-----------+
                             |
                            ALB
                             |
                       HTTPS : 443
                             |
                   +---------+---------+
                   |                   |
           PrivateSubnetA       PrivateSubnetB
           10.0.11.0/24         10.0.12.0/24
                   |                   |
              ECS Task             ECS Task
              10.0.11.x            10.0.12.x
                   |                   |
                   +---------+---------+
                             |
                            RDS
                       private subnet
The Internet never connects directly to your ECS tasks.

Instead:

Internet
   ↓
ALB
   ↓
ECS Service
   ↓
Fargate Task
That is exactly the design you usually want.

20. Security Groups

A Security Group is basically a virtual firewall attached to a network interface/resource.

Suppose the ALB has:

ALB Security Group
You may configure:

Inbound

TCP 443
Source: 0.0.0.0/0
Meaning:

Allow HTTPS from Internet
Then your ECS tasks get a different security group:

ECS Security Group
Inbound:

TCP 8080
Source: ALB Security Group
Notice that I did not write:

Source: 0.0.0.0/0
That would unnecessarily expose the application.

Instead:

Internet
    |
   443
    |
  ALB SG
    |
   8080
    |
 ECS SG
Only the load balancer is allowed to access the container.

This is an important security principle.

21. Security Group references

One of the best AWS networking patterns is:

Application SG allows traffic from ALB SG
rather than writing IP ranges.

For example:

ALB-SG

Inbound:
443 from 0.0.0.0/0
and:

ECS-SG

Inbound:
8080 from ALB-SG
Then even if the ALB's IP addresses change, everything continues working.

22. Security Groups are stateful

Security Groups are stateful.

Suppose you allow:

Inbound:
TCP 8080
ALB -> ECS
When the ECS task sends the response back, AWS automatically allows the reply traffic.

You don't need to separately configure the return flow.

This is different from Network ACLs.

23. Network ACL

A Network ACL, or NACL, is another network security layer.

The distinction is:

Security Group
applies to network interfaces/resources

NACL
applies to the subnet
Also:

Security Group = stateful

NACL = stateless
With NACLs, inbound and outbound rules must be considered separately.

For most applications, Security Groups are your primary control.

I normally tell junior engineers:

Don't make NACLs unnecessarily complicated unless you have a clear security requirement.

Incorrect NACL rules are a common cause of mysterious connectivity problems.

24. Availability Zones

Suppose Frankfurt has:

eu-central-1a
eu-central-1b
eu-central-1c
These represent separate AWS infrastructure locations.

You don't want both application servers in one AZ:

AZ-A

Task 1
Task 2
because if AZ-A has a major failure, both tasks disappear.

Instead:

AZ-A                 AZ-B

Task 1               Task 2
This is why you create subnets across different AZs.

25. Why you often create two public subnets

Application Load Balancers should normally span at least two Availability Zones.

Therefore:

PublicSubnetA
PublicSubnetB
Then the ALB is deployed across both.

Similarly ECS uses:

PrivateSubnetA
PrivateSubnetB
So ECS tasks can be distributed across AZs.

26. Example complete subnet plan

For ePG I might design:

VPC
10.20.0.0/16
Subnets:

PublicSubnetA
10.20.1.0/24
eu-central-1a

PublicSubnetB
10.20.2.0/24
eu-central-1b
Application:

PrivateAppSubnetA
10.20.11.0/24
eu-central-1a

PrivateAppSubnetB
10.20.12.0/24
eu-central-1b
Database:

PrivateDBSubnetA
10.20.21.0/24
eu-central-1a

PrivateDBSubnetB
10.20.22.0/24
eu-central-1b
You still have a huge amount of VPC address space left for future services.

27. Why not make everything public?

Technically you could place ECS Fargate tasks in public subnets and give them public IPs.

But production architecture normally follows the principle:

Expose only what must be exposed.
Your application container itself doesn't need to be exposed.

The only Internet-facing component should normally be:

ALB
Therefore:

Internet
↓
ALB
↓
private ECS
↓
private DB
is better than:

Internet
↓
public ECS
↓
database
28. Private IP example

Suppose ECS launches three tasks:

Task 1
10.20.11.15

Task 2
10.20.12.18

Task 3
10.20.11.19
You should not normally care about these exact addresses.

ECS may terminate and recreate a task:

Task 1
10.20.11.15
disappears.

New task:

10.20.11.36
That's why you don't configure clients to connect to ECS task IP addresses.

Instead you use the Load Balancer.

29. Elastic Network Interface — ENI

This is another term you'll see constantly.

An ENI is:

Elastic Network Interface
Think of it as a virtual network card.

It can contain:

private IP
security groups
MAC address
network configuration
With ECS Fargate using:

awsvpc
each task receives its own ENI.

So conceptually:

Fargate Task
     |
    ENI
     |
Private IP
10.20.11.24
This is one reason subnet IP sizing is important.

30. Why subnet sizing matters for Fargate

Imagine:

Private subnet:
/28
You only get 11 usable AWS IP addresses.

Then you run:

6 ECS tasks
other ENIs
load balancer related networking
AWS infrastructure
You could run out of IP addresses.

Then ECS may report errors similar to:

unable to provision task network interface
As a production DevOps engineer, always check:

AvailableIpAddressCount
when diagnosing ECS networking capacity issues.

31. DNS

IP addresses are difficult for people and applications to manage.

Therefore we use DNS.

Instead of:

3.123.84.22
we use something like:

epg.example.com
DNS could point toward your Application Load Balancer.

For example:

epg.company.com

       ↓ DNS

Application Load Balancer

       ↓

ECS Fargate
On AWS this is commonly handled with:

Route 53
32. Example request flow

Suppose the user visits:

https://epg.company.com
Here's what happens:

1. DNS resolves epg.company.com.

2. DNS returns the ALB.

3. User connects to ALB on TCP 443.

4. ALB Security Group checks:
   Is 443 allowed?

5. ALB terminates HTTPS.

6. ALB chooses a healthy ECS task.

7. ALB sends request to:
   10.20.11.25:8080

8. ECS Security Group checks:
   Does ALB SG have permission for 8080?

9. Container processes request.

10. Response goes:
    ECS -> ALB -> User
Understanding this flow makes troubleshooting AWS much easier.

33. Example outbound flow

Now your application needs to call:

https://api.somecompany.com
The ECS task is private:

10.20.11.25
Flow:

ECS Task
10.20.11.25

      ↓

Private Route Table

0.0.0.0/0
→ NAT Gateway

      ↓

NAT Gateway
public IP 18.x.x.x

      ↓

Internet Gateway

      ↓

Internet API
The external API sees the NAT Gateway's public IP rather than:

10.20.11.25
because private IP addresses aren't routable on the Internet.

34. Why NAT is useful for IP whitelisting

Suppose an external provider says:

Give us your source IP so we can whitelist your application.

You normally don't give them your ECS task IP.

Tasks change constantly.

Instead:

ECS Task
      ↓
NAT Gateway
      ↓
Elastic IP
The NAT Gateway can have a stable Elastic IP.

For example:

18.185.20.50
Then you tell the provider:

Whitelist:
18.185.20.50
All ECS outbound Internet traffic can appear from that address.

35. Elastic IP

An Elastic IP is a static public IPv4 address allocated to your AWS account.

For example:

18.185.20.50
You can assign one to resources such as:

NAT Gateway
certain EC2 scenarios
This is useful when another organization requires a fixed source IP.

36. VPC endpoints

There's another important design concept.

Suppose ECS needs:

ECR
S3
CloudWatch
Secrets Manager
You could route that traffic through:

NAT Gateway
→ Internet/AWS public endpoints
But AWS supports VPC Endpoints.

Then traffic can remain on AWS networking:

Private ECS
       |
       |
VPC Endpoint
       |
      ECR
instead of:

Private ECS
       |
NAT Gateway
       |
Internet path
       |
ECR
Benefits can include:

better isolation
reduced NAT dependency
possible cost optimization
private connectivity
For ECS-heavy architectures, endpoints for services like ECR, S3, CloudWatch Logs, Secrets Manager and Systems Manager can be very useful.

37. Three different meanings of "private"

This often confuses junior engineers.

When someone says:

This server is private.

Ask what exactly they mean.

They could mean:

Private IP

10.x.x.x
Private subnet

No direct route to Internet Gateway.

Security restricted

Security Group doesn't permit Internet access.

These are related but not identical concepts.

38. Public subnet definition you should remember

A good interview-quality definition:

A public subnet is a subnet whose route table contains a route to an Internet Gateway.

Usually:

0.0.0.0/0 -> IGW
A private subnet does not have a direct route to an Internet Gateway.

It may instead have:

0.0.0.0/0 -> NAT Gateway
39. Common misconception

People sometimes say:

This subnet has public IP addresses, therefore it's public.

That isn't technically the correct definition.

The deciding factor is routing.

A resource needs all the required pieces:

public IP
+
IGW
+
route
+
security rules
to communicate directly with the Internet.

40. Think in layers when troubleshooting

As a senior engineer, when somebody says:

ECS cannot connect to the Internet.

Don't randomly modify Security Groups.

Work systematically.

Check:

1. Does the task have an IP?

2. Which subnet is it in?

3. Which route table is associated?

4. Is there a default route?

5. Does that route point to NAT?

6. Is the NAT Gateway healthy?

7. Is NAT in a public subnet?

8. Does NAT's public subnet have:
   0.0.0.0/0 -> IGW?

9. Does the NAT Gateway have an Elastic IP?

10. Does the task Security Group allow outbound traffic?

11. Does the NACL allow traffic?

12. Is DNS resolution working?
That mindset is much more valuable than memorizing AWS menus.

41. Same method for inbound problems

Suppose:

ALB is returning 502 or timeout.

Trace the path:

User
↓
DNS
↓
ALB
↓
ALB Listener
↓
Target Group
↓
ECS ENI
↓
Container Port
↓
Application
Check each layer.

For example:

ALB listener:
443

Target group:
8080

ECS container:
8080

Security group:
ALB SG -> ECS SG TCP 8080

Application:
listening on 0.0.0.0:8080
If your Java app listens only on:

localhost:8080
the ALB cannot reach it even though everything in AWS networking may be correct.

42. A very important distinction: port vs IP

Consider:

10.20.11.25:8080
There are two pieces:

10.20.11.25 = IP address

8080 = TCP port
The IP tells AWS:

Which network interface/device?

The port tells the device:

Which application/service?

For example:

22   SSH
80   HTTP
443  HTTPS
3306 MySQL
5432 PostgreSQL
8080 Common Java application port
43. How this relates to your ePG application

Let's imagine ePG runs inside Docker:

Tomcat / Spring Boot
Port 8080
The Fargate task gets:

10.20.11.23
The ALB communicates with:

10.20.11.23:8080
Another task might get:

10.20.12.17:8080
Target group:

Target 1
10.20.11.23:8080

Target 2
10.20.12.17:8080
The load balancer distributes traffic across those tasks.

44. What assignPublicIp means in ECS

You will encounter this in CloudFormation:

NetworkConfiguration:
  AwsvpcConfiguration:
    AssignPublicIp: DISABLED
For our recommended architecture:

Private subnets
+
NAT Gateway
I would normally use:

AssignPublicIp: DISABLED
because ECS tasks should not need public IP addresses.

The ALB communicates with them through their private addresses.

45. CloudFormation representation

Conceptually you'll eventually have resources such as:

VPC:
  Type: AWS::EC2::VPC
Then:

PublicSubnetA:
  Type: AWS::EC2::Subnet
and:

PrivateSubnetA:
  Type: AWS::EC2::Subnet
Then:

InternetGateway:
  Type: AWS::EC2::InternetGateway
followed by:

PublicRouteTable
PrivateRouteTable
NATGateway
SecurityGroups
So when writing your ePG CloudFormation template, networking is not random AWS boilerplate. Every object corresponds to one of the concepts above.

46. Architecture I would recommend for ePG

At a minimum:

                   INTERNET
                      |
                   Route53
                      |
                     ALB
                /           \
          Public A         Public B
            |                 |
          NAT-A             NAT-B
            |                 |
        Private A         Private B
            |                 |
         ECS Task           ECS Task
                \           /
                   Database
For a less expensive dev environment you may use one NAT Gateway:

1 NAT
2 private subnets
For production, having NAT Gateways per AZ gives better resilience.

There is a cost tradeoff.

47. Dev vs production

For development you might choose:

2 public subnets
2 private subnets
1 NAT Gateway
because NAT Gateways cost money.

For production:

2 public subnets
2 private application subnets
2 private DB subnets

1 NAT Gateway per AZ
This improves availability.

48. Network diagram to memorize

Keep this model in your head:

                         INTERNET
                             |
                             |
                       +-----------+
                       |    IGW    |
                       +-----------+
                             |
                ---------------------------
                |                         |
        Public Subnet A           Public Subnet B
        10.0.1.0/24               10.0.2.0/24
                |                         |
               ALB                       ALB
                |
        -------------------
        |                 |
Private Subnet A    Private Subnet B
10.0.11.0/24        10.0.12.0/24
        |                 |
    ECS Task           ECS Task
        |                 |
        -------------------
                |
               RDS
          private DB subnet
Outbound Internet:

ECS
 ↓
NAT Gateway
 ↓
IGW
 ↓
Internet
Inbound Internet:

Internet
 ↓
IGW
 ↓
ALB
 ↓
ECS
Notice:

Internet does NOT directly access ECS.
That is the core design principle.

49. The five AWS network objects you must master first

As a junior DevOps engineer, focus on these in this order:

1. VPC

What network does my application live in?
2. Subnet

Which IP range and AZ does my resource use?
3. Route Table

Where does network traffic go?
4. Security Group

Who is allowed to communicate with the resource?
5. IGW / NAT

How does Internet connectivity happen?
Once you understand those five, AWS networking becomes much easier.

50. One sentence definitions worth remembering

Use these when talking to another engineer:

VPC

An isolated virtual network in AWS containing our application's network resources.

Subnet

A smaller CIDR range within a VPC that belongs to one Availability Zone.

Public subnet

A subnet whose route table has a direct route to an Internet Gateway.

Private subnet

A subnet without a direct route to an Internet Gateway.

Route table

Rules defining where network traffic for different destination networks should be sent.

Internet Gateway

The VPC component that enables Internet-routable communication.

NAT Gateway

Allows resources in private subnets to initiate outbound Internet connections without being directly reachable from the Internet.

Security Group

A stateful firewall attached to AWS network interfaces/resources.

NACL

A stateless subnet-level traffic filter.

ENI

A virtual network interface carrying IP addresses and security-group associations.

The senior-engineer mental model

Whenever you design or troubleshoot AWS, don't start with AWS service names. Ask four questions:

1. Where is the source?
2. Where is the destination?
3. What route will the packet take?
4. What security controls must allow it?
For example:

User -> ePG
becomes:

Source:
Internet

Destination:
ECS Fargate

Path:
Internet
-> IGW
-> ALB
-> private subnet
-> ECS ENI

Security:
ALB SG allows 443
ECS SG allows 8080 from ALB SG
For ECS calling an external API:

Source:
ECS private IP

Destination:
Internet API

Path:
ECS
-> private route table
-> NAT Gateway
-> public route table
-> IGW
-> Internet

Security:
ECS outbound allowed
NACLs permit traffic
If you learn to think in source → destination → route → security, you'll be able to diagnose most AWS networking issues systematically instead of guessing.