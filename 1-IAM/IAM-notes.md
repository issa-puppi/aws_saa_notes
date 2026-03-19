# IAM Principals must be authenticated to send requests
    - An IAM Principal is a person/app that can make a request 
      for an action or operation on an AWS resource

AWS determines wether to allow/deny the request based on the 
policies attached to the IAM Principal
    - Policies are documents that define permissions for an IAM Principal
    - Policies can be attached to users, groups, or roles (identity-based)
    - Policies can also be attached to resources (resource-based)

# Every resource has a friendly name and an Amazon Resource Name (ARN)
    - ARN is a unique identifier for the resource
    - ARN format: arn:partition:service:region:account-id:resource-type/resource-id

# IAM User Groups are collections of IAM Users
    - Groups allow you to manage permissions for multiple users at once
    - You can attach policies to groups, and all users in the 
      group will inherit those permissions
    - Users can be in multiple groups, and permissions are cumulative
        * Example: You can have a "Developers" group with permissions
          to access development resources, and a "Admins" group with 
          permissions to access all resources. A user in both groups 
          would have permissions from both groups.

Can authenticate using:
    - Access Keys (for programmatic access) via AWS CLI, SDKs, or APIs
    - Passwords (for AWS Management Console access)
    - Multi-Factor Authentication (MFA) for added security

# My IAM User link: https://ijpc-training.signin.aws.amazon.com/console (username = ijpc-training)
# My IAM Root link: https://console.aws.amazon.com/ (reminder to login with root email button)

# Permissions Boundaries:
    - A permissions boundary is an advanced feature for using a managed policy 
      to set the maximum permissions that an IAM entity (user or role) can have.
        * can be assigned to an IAM user or role, but not to a group
    - It does not grant permissions by itself, but it limits the permissions that 
      can be granted to the entity (equal to or less than the permissions boundary).
    - When you set a permissions boundary for an IAM entity, the effective permissions 
      for that entity are the intersection of the permissions granted by its identity-based 
      policies and the permissions allowed by the permissions boundary.

# Priviledged Escalation (attack):
    - Occurs when an IAM user or role gains more permissions than intended, often through 
      misconfigured policies or by assuming a role with higher privileges.
    - To prevent this, follow the principle of least privilege, regularly review permissions, 
      and use permissions boundaries to limit the maximum permissions an entity can have.

To prevent this type of attack, users can only create roles or permissions with permissions 
that are equal to or less than their own permissions. This is known as "permissions boundary" 

# Service Control Policies (SCPs):
    - SCPs are a type of policy used in AWS Organizations to manage permissions across multiple accounts.
    - SCPs allow you to set permission guardrails for your organization, ensuring that accounts 
      adhere to specific security and compliance requirements.
    - SCPs do not grant permissions by themselves but instead limit the permissions that can be granted 
      to IAM entities within the accounts they are applied to.

SCPs differ from permissions boundaries in that SCPs are applied at the organizational level and 
affect all accounts within the organization, while permissions boundaries are applied at the 
individual IAM entity level and only affect that specific entity.

# SCP = organization-wide policy limit
# Permissions Boundary = individual user/role policy limit

# Permission evaluation logic hierachy:
    1. Is there an explicit deny in any applicable policy? 
       If yes, the request is denied (explicit). (Applies to all denials policies)

    2. Is the principal's account a member of an organization with an SCP that denies the action? 
       Is there an Allow? If no, the request is denied (implicit).
       
    3. Does the requested resource have a resource-based policy that explicitly denies the action? 
       Is there an Allow? If yes, check policy, otherwise continue to next step.

    4. Doe the principal have an identity-based policy that explicitly denies the action? 
       Is there an Allow? If no, the request is denied (implicit).
       
    5. Does the principal have a permissions boundary that explicitly denies the action? 
       Is there an Allow? If no, the request is denied (implicit).
       
    6. Is the principal a session principal? If no, then it is Allowed.
       If yes, is there a session policy? If yes, is there an Allow? If yes, then it is Allowed.
       If no, is there a role session? If yes, then it is Allowed. If no, then it is Denied (implicit).

    7. Final Decision: Allow or Deny based on the evaluation of all applicable policies and conditions.

# In short:
    - Explicit Deny
    - SCP Deny
    - Resource-based Deny
    - Identity-based Deny
    - Permissions Boundary Deny
    - Session Policy Deny
    - Role Session Allow
    - Allow (if no denies are found)

Requests can come from the console, CLI or API, and the evaluation logic applies to all types of requests.

# Stage 1 is authentication based upon resource context 
    * (consisted of actions, resources, principal, environmental data and resource data)
    A.K.A. what they want to do, what they want to do it to, who they are (role), information 
    about their system that is making the request, and information about what they are asking about

# Role vs Policy:
    - A role is an AWS identity with specific permissions that can be assumed by trusted entities, while a policy is a document that defines permissions for an identity (user, group, or role) or resource. 
    - Roles are used to delegate access to users or services without sharing long-term credentials, while policies are used to specify what actions are allowed or denied for those identities or resources.

# Role = defines what permissions an entity has when they assume the role
# Policy = defines what permissions an entity has when they are attached to it 
    * (user, group, role, resource, etc.)
# Role is an identity, policy is a set of permissions attached to an identity or resource

# Types of Policies:
    - Identity-based policies: attached to users, groups, or roles (e.g., IAM policies)
    - Resource-based policies: attached to resources (e.g., S3 bucket policies)
    - Permissions boundaries: set maximum permissions for an IAM entity
    - Service Control Policies (SCPs): applied at the organizational level in AWS Organizations or OU
    - Session policies: passed when assuming a role (API actions) and are evaluated during the session

# Determination rules:
    - by default, all requests are implicitly denied (excluding the root user)
    - an explicit allow in an identity-based policy or resource-based policy obviates the 
      implicit deny, but does not override an explicit deny in any policy
    - if a permissions boundary, organizational SCP or session policy is present, it might 
      override the allow with an implicit deny depending on the conditions 
    - an explicit deny in any policy overrides any allow in any policy

# Analogy:
    - Identity-based policy = ID badge
    - Permissions boundary = security guard at the gate
    - Resource-based policy = room acess list
    - Organizational SCP = company-wide rules

# Allow is Union/OR, Deny is Intersection/AND (in a logic gate sense)

Evey action in AWS is an API Action/Call (denoted by "Action: name-of-action") 
and is evaluated against the policies to determine if it is allowed or denied.

# IAM Policies are JSON documents that define the permissions for an IAM Principal (allow/deny)
    - effect: "Allow" or "Deny"
    - action: list of actions that are allowed or denied
    - resource: list of resources that the actions apply to (bucket, object, etc.)
    - condition: optional conditions that must be met for the policy to apply 
        (e.g., time of day, IP address, etc.)

# IAM Policy Simulator allows you to evaluate and test the effects of policies without logging in as them

# Access Analyzer automatically identifies trends and possible issues in your access levels in your account
    - helps to quickly resolve issues via warnings of excess access permissions

# Security Token Service (STS) allows you to request temporary credentials for IAM users or roles
    - useful for federated access, cross-account access, and temporary access for applications

# AWS Best Practices: (link: https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

    - require human users to use federations (third party identity provider) to access AWS with temp creds
    - require workloads to use temporary credentials with IAM roles to access AWS
    - require MFA
    - rotate access keys regularly for long term credential use cases
    - safeguard root user creds and don't use for everyday tasks
    - apply least-priviledge permissions (users and apps)
    - use AWS managed policies and then move towards least-priviledged permissions (fine tuning)
    - use IAM Access Analyzer to generate least-priviledged policies based on access activity
    - regularly review and remove unused users, roles, permissions, policies and credentials
    - use conditions in IAM policies to further restrict access
    - verify public and cross-account access to resources with IAM Access Analyzer
    - validate IAM policies 
    - establish permission guardrails across multiple accounts (via AWS Orgs and Control Tower)
    - use permission boundaries to delegate permissions management within an account

# Exam Cram:
    - CLI is a tool to interact with AWS services using commands in your command-line shell
    - IAM users can be created to represent applications or services that need to interact with AWS resources
        * These are known as "service accounts" 
    - 5000 user limit per AWS account
    - IAM groups are collections of IAM users and can be used to manage permissions for multiple users
    - IAM roles are similar to users but are meant to be assumed by trusted entities 
      (users, applications, or services) and do not have long-term credentials)

# Cheat sheet: https://digitalcloud.training/aws-iam/