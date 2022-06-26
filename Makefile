APPLICATION_NAME = hello
APPLICATION_DIRECTORY = src/lambda-go-develop-template/

.PHONY: build run stop push-ecr update-lambda help

# if you want to push the image to ECR or update Lambda function
# make tag=<image tag name> <push-ecr|update-lambda>
ifdef tag
	TAG=${tag}
endif

help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

build: ## Build the docker image.
	@docker build -t ${APPLICATION_NAME}:latest ${APPLICATION_DIRECTORY}

run: ## Run the container from built image.
	@docker run -d --rm -p 9000:8080 --name ${APPLICATION_NAME} ${APPLICATION_NAME}:latest

stop: ## Stop the container.
	@docker stop ${APPLICATION_NAME}

get-tag:
	@if [ -z "${TAG}" ] ; then echo "Please specify the docker image tag name(tag)" ; $(call help); exit 1; fi

push-ecr: get-tag build ## Push the image to AWS ECR repository with the same name as application. Retrieve the tag from tag=<tag name>.
	$(eval export AWS_ACCOUNT_ID := $(shell aws sts get-caller-identity --output text --query Account))
	@if [[ -z "$(AWS_ACCOUNT_ID)" ]]; then echo "AWS_ACCOUNT_ID could not be set"; exit 1; fi
	@aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com
	@docker tag error-mail-notifier:latest $${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${APPLICATION_NAME}:${DEPLOY_DATE}
	@docker push $${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${APPLICATION_NAME}:${DEPLOY_DATE}

update-lambda: get-tag ## Update the lambda function to refer to the image pushed to ECR.
	$(eval export AWS_ACCOUNT_ID := $(shell aws sts get-caller-identity --output text --query Account))
	@if [[ -z "$(AWS_ACCOUNT_ID)" ]]; then echo "AWS_ACCOUNT_ID could not be set"; exit 1; fi
	@aws lambda update-function-code --function-name ${APPLICATION_NAME} --image-uri ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${APPLICATION_NAME}:${DEPLOY_DATE}
