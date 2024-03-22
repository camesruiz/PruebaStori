# Thumbnail Generator

This repository contains an implementation of a thumbnail
generator. Program takes an .JPG image, resizes it and 
returns it as a 100px x 100px thumbnail.

Implementation is done using API Gateway to upload the image,
AWS S3 for the images storage, AWS Lambda for the image processing, 
Terraform for the infrastructure setting, 
Circle CI for the deploying process.

## Project Overview

```
PruebaStori
├── .circleci           # CI/CD pipeline
│   ├── config.yml
├── infra               # Terraform files
│   ├── main.tf
├── lambda_function     # Lambda source code
│   ├── lambda_function.py
├── test                # Unit testing functions
│   ├── __init__.py
│   ├── test_lambda_function.py
├── .gitignore
└── README.md
```

User sends a PUT request along with the JPG file to the url:
```
https://5ktsx96fvk.execute-api.us-east-1.amazonaws.com/dev/camesruiz-stori-images/original/{filename}
```
To save it in a S3 bucket. **filename** is how the user wants the file to be stored.
Once the new file is stored in S3, a lambda function is triggered that will
generate a thumbnail from the uploaded image.

Thumbnail images will be available at:
```
s3:/camesruiz-stori-thumbnails//tmp/
```

### Deployment
Deployment is made through a CI/CD pipeline using CircleCI

#### Build and Test:

- Packages installation
- Unit test execution

#### Deployment:

- Packages and code zipping
- Package upload to S3
- Lambda function update

## Strengths and Weaknesses

- Code working on a serverless mode avoiding the need of provisioning servers
- Easy to integrate to an external service (e.g. Web service) using the API
- Infrastructure well documented using Terraform, making it easy to manage, version and replicate
- Automated deployment and testing enhancing de developing experience
- Lambda functions are automatically scalable ensuring service availability
- API Gateway provide a secure solution for REST APIs, making it reliable in terms of app security
- Still to develop a way to implement a single request for uploading the image and downloading the thumbnail
- Lambda functions represent execution limits related to timeout and memory
- Limited portability due the whole architecture being implemented over one single cloud vendor