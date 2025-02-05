# Ubuntu 22.04 and Cuda 12.4.1
FROM ghcr.io/civo-learn/civo-python-cuda12:latest

# activate micromamba env.
ARG MAMBA_DOCKERFILE_ACTIVATE=1

# pypi dependacies
COPY --chown=$MAMBA_USER:$MAMBA_USER requirements.txt /tmp/requirements.txt

# install the python deps
RUN python3 -m pip install --no-cache-dir -r /tmp/requirements.txt

# copy over the chat templates
COPY chat-templates /chat-templates

# copy over the entry point
COPY --chown=$MAMBA_USER:$MAMBA_USER entrypoint.sh /
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]
