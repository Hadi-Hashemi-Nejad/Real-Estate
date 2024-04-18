FROM public.ecr.aws/lambda/python:3.11

RUN pwd

# Copy requirements.txt
COPY Image/requirements.txt ${LAMBDA_TASK_ROOT}

# Install the specified packages
RUN pip install -r requirements.txt

# Copy all files in ./src
COPY Image/src/* ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler.
CMD [ "main.handler" ]