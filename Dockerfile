# Ubuntu 22.04 and Cuda 12.4.1
FROM ghcr.io/civo-learn/civo-python-cuda12:latest

# activate micromamba env
ARG MAMBA_DOCKERFILE_ACTIVATE=1

# pypi dependacies
COPY --chown=$MAMBA_USER:$MAMBA_USER requirements.txt /tmp/requirements.txt

# install the python deps
RUN python3 -m pip install --no-cache-dir -r /tmp/requirements.txt


CMD ["python3", "-m", "vllm.entrypoints.openai.api_server", "--tensor-parallel-size", "1", "--worker-use-ray", "--host", "0.0.0.0", "--port", "8080", "--model", "meta-llama/Meta-Llama-3-8B", "--served-model-name", "meta-llama/Meta-Llama-3-8B"]

# copy over the entry point
# COPY --chown=$MAMBA_USER:$MAMBA_USER entrypoint.sh /usr/local/bin/

# Run the entrypoint
# ENTRYPOINT ["entrypoint.sh"]
# ENTRYPOINT ["/bin/bash", "/usr/local/bin/entrypoint.sh"]
