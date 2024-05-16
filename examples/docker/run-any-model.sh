!/bin/bash

# This script builds the docker image and runs the container with the specified model and port passed as a command-line argument.
# For example, to run the "llama2" model, you can use the following command:
# ./run-any-model.sh llama2 11434

# Ensure the model name and port is provided as a command-line argument
if [ $# -ne 2 ]; then
    echo "Usage: $0 <model_name> <port_number>"
    exit 1
fi

# Assign the provided model name to a variable
MODEL=$1

# Assign the provided port number to a variable
PORT=$2

# Build the docker image
IMAGE_NAME="ghcr.io/civo-learn/civo-vllm-docker:latest"
docker build -t $IMAGE_NAME .

# Run the docker container with the specified model
docker run -d -e HF_TOKEN=$HF_TOKEN -e MODEL=$MODEL -p 8080:8080 $IMAGE_NAME

# Test the model
sleep 10
curl -s -X POST http://localhost:$PORT/api/generate -d '{
  "model": "'"$MODEL"'",
  "stream": false,
  "prompt": "what is the value of fibonacci golden ratio?"
}'
