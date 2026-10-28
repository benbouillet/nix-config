FROM docker.io/library/python:3.15.1-slim-bookworm@sha256:57f8539684eacb0932ead2cb9ed1f5fc9a5995a0ed6a8cd48d6819804c9133e6

RUN apt-get update \
    && apt-get install --yes --no-install-recommends bash \
    && rm -rf /var/lib/apt/lists/* \
    && python -m pip install --no-cache-dir uv==0.8.17

WORKDIR /tmp
CMD ["bash"]
