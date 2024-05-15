FROM public.ecr.aws/lambda/python:3.11

RUN pwd

# Copy requirements.txt
COPY Images/Image_Bayut_API/requirements.txt ${LAMBDA_TASK_ROOT}

# Install the specified packages
RUN pip install -r requirements.txt

# Copy all files in ./src
COPY Images/Image_Bayut_API/src/* ${LAMBDA_TASK_ROOT}

# Copy credentials file
COPY terraform.tfvars ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler.
CMD [ "main.handler" ]