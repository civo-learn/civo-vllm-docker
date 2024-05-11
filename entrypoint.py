import os
import subprocess
import sys
import argparse
from vllm.model_executor.engine_args import EngineArgs
from vllm.entrypoints.openai.api_server import run_server

def check_nvidia_smi():
    """Ensure NVIDIA drivers are installed and get the number of GPUs."""
    try:
        num_gpus = subprocess.check_output("nvidia-smi -L | wc -l", shell=True).decode().strip()
    except subprocess.CalledProcessError:
        print("nvidia-smi could not be found. Ensure NVIDIA drivers are installed.")
        sys.exit(1)
    return int(num_gpus)

def get_additional_args():
    """Construct additional command line arguments based on environment variables."""
    additional_args = []
    quantization = os.getenv('QUANTIZATION')
    dtype = os.getenv('DTYPE')

    if quantization:
        if not dtype:
            print("Missing required environment variable DTYPE when QUANTIZATION is set")
            sys.exit(1)
        additional_args.extend(['-q', quantization, '--dtype', dtype])

    gpu_mem_util = os.getenv('GPU_MEMORY_UTILIZATION')
    if gpu_mem_util:
        additional_args.extend(['--gpu-memory-utilization', gpu_mem_util])

    max_model_len = os.getenv('MAX_MODEL_LEN')
    if max_model_len:
        additional_args.extend(['--max-model-len', max_model_len])

    # Example of handling other optional configurations
    # chat_template = os.getenv('CHAT_TEMPLATE')
    # if chat_template:
    #     additional_args.extend(['--chat-template', chat_template])

    return additional_args

def main():
    num_gpu = check_nvidia_smi()
    model = os.getenv('MODEL')
    if not model:
        print("Missing required environment variable MODEL")
        sys.exit(1)

    served_model_name = os.getenv('SERVED_MODEL_NAME', model)
    port = os.getenv('PORT', '8080')
    
    parser = argparse.ArgumentParser(description="vLLM API Server")
    EngineArgs.add_cli_args(parser)
    args = parser.parse_args([])  # Load defaults

    # Override defaults with either command line (through parser) or environment variables
    args.tensor_parallel_size = num_gpu
    args.worker_use_ray = True
    args.host = '0.0.0.0'
    args.port = int(port)
    args.model = model
    args.served_model_name = served_model_name.split()  # Support list of model names
    
    additional_args = get_additional_args()
    if additional_args:
        # Update args by re-parsing with additional_args
        args = parser.parse_args(additional_args, namespace=args)

    run_server(args)

if __name__ == "__main__":
    main()
