FROM docker.io/library/python:3.15.2-slim-bookworm@sha256:438fab931960f54d2bf2e19b4a89660a77d4e719688be1e565d75d0b43a8511f

RUN apt-get update \
    && apt-get install --yes --no-install-recommends bash \
    && rm -rf /var/lib/apt/lists/* \
    && python -m pip install --no-cache-dir uv==0.8.17

WORKDIR /tmp
CMD ["bash"]
