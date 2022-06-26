# lambda-go-develop-template

This repository is template to develop AWS Lambda that assumed to use ECR.

## How to use this repository

1. Select `Use this template` button on this repository and create your repository.
2. The code is under the `src` directory.
   1. As a sample, there is `lambda-go-develop-template` which returns `{"Message":"Hello world"}`.
3. After you create the lambda, you can build and run using `make build` and `make run`. Please freely rewrite `APPLICATION_NAME` and `APPLICATION_DIRECTORY` of `Makefile`. You can stop using `make stop`.
   1. If you build and run the template, you can call `Hello world` with following command.
       ```
       $ curl "http://localhost:9000/2015-03-31/functions/function/invocations"
       ```
4. If you want to push the image to ECR repository, you can push with `make push-ecr tag=<docker tag name>`.
5. Then you can update the lambda function with `make update-lambda tag=<same tag as above>`.
