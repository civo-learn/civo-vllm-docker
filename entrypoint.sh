# based on: https://github.com/substratusai/vllm-docker/blob/main/entrypoint.sh
# which itself is based off: https://github.com/vllm-project/vllm/blob/main/vllm/engine/arg_utils.py
#!/usr/bin/env bash

# Enable debugging
set -x

# Ensure the script exits on any error
set -e

# Attempt to detect the number of GPUs
if command -v nvidia-smi &>/dev/null; then
    export NUM_GPU=$(nvidia-smi -L | wc -l)
else
    export NUM_GPU=0
fi

# If there should be GPUs, ensure 'nvidia-smi' is available
if [ "$NUM_GPU" -gt 0 ]; then
    if ! command -v nvidia-smi &>/dev/null; then
        echo "Error: 'nvidia-smi' could not be found. Ensure NVIDIA drivers are installed."
        exit 1
    fi
fi

# Define the model to be served, default to $MODEL if not specified
export SERVED_MODEL_NAME=${SERVED_MODEL_NAME:-$MODEL}

# Ensure MODEL environment variable is set
if [[ -z "$MODEL" ]]; then
    echo "Error: Missing required environment variable 'MODEL'."
    exit 1
fi

# Set default PORT to 8080 if not provided
export PORT=${PORT:-8080}

# Initialize additional arguments
additional_args=${EXTRA_ARGS:-""}

# Check and handle QUANTIZATION related settings
if [[ -n "$QUANTIZATION" ]]; then
    if [[ -z "$DTYPE" ]]; then
        echo "Error: Missing required environment variable 'DTYPE' when 'QUANTIZATION' is set."
        exit 1
    else
        additional_args="$additional_args -q $QUANTIZATION --dtype $DTYPE"
    fi
fi

# Add GPU memory utilization setting to arguments if provided
if [[ -n "$GPU_MEMORY_UTILIZATION" ]]; then
    additional_args="$additional_args --gpu-memory-utilization $GPU_MEMORY_UTILIZATION"
fi

# Add maximum model length to arguments if provided
if [[ -n "$MAX_MODEL_LEN" ]]; then
    additional_args="$additional_args --max-model-len $MAX_MODEL_LEN"
fi

if [[ ! -z "${CHAT_TEMPLATE}" ]]; then
    additional_args="${additional_args} --chat-template ${CHAT_TEMPLATE}"
fi

# Start the API server with the specified or default settings
python3 -m vllm.entrypoints.openai.api_server \
    --tensor-parallel-size $NUM_GPU \
    --host 0.0.0.0 \
    --port "$PORT" \
    --model "$MODEL" \
    --served-model-name "$SERVED_MODEL_NAME" $additional_args

