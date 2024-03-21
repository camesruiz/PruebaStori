# Thumbnail Generator

This repository contains an implementation of a thumbnail
generator. Program takes an .JPG image, resizes it and 
returns it as a 100px x 100px thumbnail.

Implementation is done using AWS S3 for the images storage,
AWS Lambda for the image processing, Terraform for the 
infrastructure setting, Circle CI for the deploying process.

## Project Overview

PruebaStori
├── infra               # Terraform files
│   ├── main.tf
├── lambda_function     # Lambda source code
│   ├── main.py
├── test                # Unit testing functions
│   ├── __init__.py
│   ├── test_main.py
├── .gitignore
└── README.md

