# Serverless Static Website With Basic Authentication


This repository contains a collection of Bash scripts and a choice of either a Terraform module or a set of CloudFormation templates that build a serverless infrastructure in AWS to host a static website protected with [Basic Authentication](https://en.wikipedia.org/wiki/Basic_access_authentication).
The static website is published on a subdomain registered in Route 53.

> A live example can be found at [https://serverless-static-website-with-basic-auth.dumrauf.uk/](https://serverless-static-website-with-basic-auth.dumrauf.uk/?utm_source=GitHub&utm_medium=social&utm_campaign=README) using the demo username `guest` and password [`letmein`](https://www.theguardian.com/technology/2016/jan/20/123456-worst-passwords-revealed).
> Note that access to the underlying [S3 bucket](https://us-east-1-serverless-webs-serverlesswebsitebucket-1mtsv4odbs2x0.s3.amazonaws.com) hosting the static website is denied.

The master branch in this repository is compliant with [Terraform v0.12](https://www.terraform.io/upgrade-guides/0-12.html); a legacy version that is compatible with [Terraform v0.11](https://www.terraform.io/upgrade-guides/0-11.html) is available on branch [terraform@0.11](https://github.com/dumrauf/serverless_static_website_with_basic_auth/tree/terraform%400.11).

## You Have

Before you can use the tools in this repository out of the box, you need

 - an [AWS account](https://portal.aws.amazon.com/gp/aws/developer/registration/index.html)
 - an [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) configured to work with your AWS account
 - a [domain registered with Route 53](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-register.html)
 - an [ACM certificate](http://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request.html) for the subdomain you want to publish your static website at
 - a [log bucket](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html#access-logs-choosing-s3-bucket) which can be used to store [CloudFront access logs](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html) (use the Terraform module provided in [https://github.com/dumrauf/aws_log_bucket](https://github.com/dumrauf/aws_log_bucket) to create a log bucket if needed) 

 If Terraform is the tool of choice then you also need
 - a [Terraform](https://www.terraform.io/intro/getting-started/install.html) CLI


## You Want

After creating the serverless infrastructure in AWS you get

 - a [price class 100](https://aws.amazon.com/cloudfront/pricing/) CloudFront distribution which serves your static website using HTTPS (including redirect) and the ACM certificate provided in the input
 - a private S3 bucket which contains the static website and serves as the origin for the CloudFront distribution
 - a Lambda@Edge function which runs in the CloudFront distribution and performs the Basic Authentication for all requests
 - a private S3 bucket acting as a serverless code repository
 - potentially significant cost savings over using a dedicated EC2 instance, depending on your traffic
 - the whole thing in one go while getting another coffee


## You Don't Want

Using the tools in this repository helps you avoid having

- the static website run on a dedicated EC2 instance or ECS container
- the static website to be hosted by S3 directly where it is publicly available to the whole world


## For the Impatient

All entry points are Bash scrips located in the `scripts` folder.

### Changing the Passwords

Unless you are happy with the demo username `guest` and password
[`letmein`](https://www.theguardian.com/technology/2016/jan/20/123456-worst-passwords-revealed),
swap out the username-credentials dictionary `const credentials` in file `lambda-at-edge-code/index.js` with your own.

> See the FAQs section about updating passwords at a later time in case changes are not reflected.


### One-Shot Script

The entire serverless infrastructure can be created via
```
scripts/create_static_serverless_website.sh <parameter_1> ... <parameter_n>
```
where the parameters differ between CloudFormation and Terraform and additional setup may be required.


#### CloudFormation

As for CloudFormation, the entire serverless infrastructure can be created via
```
scripts/create_static_serverless_website.sh <website-directory> <subdomain> <domain> <hosted-zone-id> <acm-certificate-arn> <profile>
```

An example invocation may look like
```
scripts/create_static_serverless_website.sh  static-website-content/  static-website mydomain.uk  Z23ABC4XYZL05B  "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"  default
```

Note that you need to replace the example values with yours in order for the script to work.

Under the bonnet, the script calls

1. `bootstrap_serverless_repo.sh`
2. `create_serverless_infrastructure.sh.sh`
3. `upload_website_to_s3_bucket.sh`

creating and uploaded the resources as indicated by the corresponding name.


#### Terraform

As for Terraform, the input variables for the example website `static-website.example.com` are definied in [`Terraform/settings/static-website.example.com.tfvars`](Terraform/settings/static-website.example.com.tfvars) as
```hcl
region = "us-east-1"

shared_credentials_file = "/path/to/.aws/credentials"

profile = "default"

hosted_zone_id = "Z23ABC4XYZL05B"

subdomain_name = "static"

domain_name = "example.com"

acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"

log_bucket_domain_name = "<your-log-bucket-domain>"
```
Note that you need to replace the example values with yours in order for Terraform to work.

With the Terraform configuration done, the entire serverless infrastructure can be created via
```
scripts/create_static_serverless_website.sh  <website-directory>  <profile>  <workspace-name>
```
Here, the `<workspace-name>` has to match the name of the input variables file in `settings/` when neglecting the `.tfvars` extension (in this case `static-website.example.com`)

An example invocation may look like
```
scripts/create_static_serverless_website.sh  static-website-content/  default  static-website.example.com
```
Note that you need to replace the example values with yours in order for the script to work.

Under the bonnet, the script calls

1. `create_serverless_infrastructure.sh.sh`
2. `upload_website_to_s3_bucket.sh`


### Syncing the Local Static Website with the S3 Bucket

The local static website contents can be synced with the corresponding S3 bucket serving as the CloudFront origin via
```
scripts/upload_website_to_s3_bucket.sh <website-directory> <profile>
```

If your static website is located at `../static-website-content/`, sync it with the corresponding S3 bucket using profile `default` via
```
scripts/upload_website_to_s3_bucket.sh  "../static-website-content/"  default
```

creating and uploaded the resources as indicated by the corresponding name.


### Using a Least Privileged User for all BAU Website Tasks

By default, an IAM user is also created who is _only allowed to_

 1. modify objects in the bucket hosting the website and
 2. create CloudFront invalidations

Using this least-privileged user's access keys minimises your potential attack surface and is highly recommended.
Note that API [access keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey) are not generated by default but can easily be obtained from the AWS console.


### Invalidating the CloudFront Distribution

After syncing the static website with the S3 bucket, the CloudFront distribution will most likely keep a cached copy of the old static website until it expires.

This process can be expedited by invalidating the cache via
```
scripts/invalidate_cloudfront_chache.sh <profile> <paths>
```

The entire CloudFront distribution can be invalidated using profile `default` via
```
scripts/invalidate_cloudfront_chache.sh default '/*'
```
Here, note the single quotes around `'/*'` in order to avoid parameter expansion in Bash.
Note that invalidations can incur [costs](http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Invalidation.html#PayingForInvalidation).


## How it Works Underneath the Bonnet

Again, the details differ when it comes to CloudFormation versus Terraform. Here, Terraform seems to simplify things a little.

In the case of CloudFormation, the Bash scripts essentially kick off two CloudFormation templates, namely

1. `bootstrap_serverless_code_repository.yaml` and
2. `serverless_static_website_with_basic_auth.yaml`

In the case of Terraform, the Bash scripts first switches to the workspace provided in the input or creates it if it doesn't exist. Afterwards, the Bash scripts essentially kick off a simple Terraform configuration in `main.tf` which utilises the `serverless-static-website-with-basic-auth` module.


### The Serverless Code Repository Template

The Serverless Code Repository template is a CloudFormation specific implementation. Here, the `bootstrap_serverless_code_repository.yaml` creates a private S3 bucket which enforces encryption and acts as a serverless code repository. Another option would be to provide the code inline in the CloudFormation template but no matter how the code editor is set up, a good chunk of the template is always being marked as either plain text or plain wrong.


### The Serverless Infrastructure Template/Module

The `serverless_static_website_with_basic_auth.yaml` template as well as the `serverless-static-website-with-basic-auth` module creates
 1. A Lambda@Edge function version which runs the Basic Authentication code
 2. A role to execute the Lambda@Edge function
 3. A CloudFront origin access identity
 4. A private S3 bucket which enforces encryption and permits the CloudFront origin access identity to read from the S3 bucket
 5. A CloudFront distribution which uses the S3 bucket previously created as the origin and has a CNAME entry for the subdomain to be registered in the next step
 6. A Route 53 RecordSetGroup which adds an A record for the subdomain to be registered and points to the CloudFront distribution URL created in the previous step


## FAQs


### Why do I have to Provide a Hosted Zone ID?

When using Route 53 as the domain registrar, a default hosted zone is usually created. This hosted zone contains four dedicated name servers.
As of December 2017, creating a new hosted zone which uses specific name servers (namely the ones from the default hosted zone) is currently not possible via CloudFormation.


### Why do I have to provide an ACM certificate ARN?

As of December 2017, CloudFormation only allows email validation for ACM certificates it issues; DNS validation is not an option even if the domain is registered via Route 53.
Moreover, the [entire stack remains in the `CREATE_IN_PROGRESS` state](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-certificatemanager-certificate.html) until the certificate has been validated which can introduce long delays.
However, the AWS console allows to create an ACM certificate and add a record set to the corresponding hosted zone in Route 53 with one click.


### I've Updated the Passwords and Redeployed the Stack but the Changes Haven't Been Reflected?

Here, the problem is that new versions are not automagically published even if the underlying code has changed. For this, the name of the version has to changed in the corresponding CloudFormation template.
Manually change the name of the `BasicAuthAtEdgeLambdaVersion` and all its uses. Another redeploy should fix the problem.


### Why is there no Alias being used in the Lambda?

As of December 2017, CloudFront can only reference a [version in Lambda@Edge](http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-requirements-limits.html).
Yup, it seems like yearly days here. Oh, and good luck deleting that Lambda@Edge via CloudFormation...


### What's the Default Root Document for the Static Website?

The default root document is `index.html`.
This value can be changed by updating the `DefaultRootObject: index.html` in the `serverless_static_website_with_basic_auth.yaml` template.


### Why is the Least Privileged User Given Full Access to CloudFront on the `cloudfront:CreateInvalidation` Permission?

As of January 2018, CloudFront does not seem to provide fine grained access control for distributions on the [`cloudfront:CreateInvalidation` permission](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cf-api-permissions-ref.html). So much for true least privileged then...


### I've got a Bug Fix/Improvement!

Splendid! Open a pull request and let's make things better for everyone!


## Credits

The code in this repository builds upon a [great article](https://hackernoon.com/serverless-password-protecting-a-static-website-in-an-aws-s3-bucket-bfaaa01b8666) by Leonid Makarov describing the underlying idea as well as providing a Node.js implementation of Basic Authentication.