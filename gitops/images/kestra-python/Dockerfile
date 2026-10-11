FROM docker.io/library/python:3.14.8-slim-bookworm@sha256:a66d3a463d0be3cc537c269b0d3418746dda512417a975559a0eaa8a6406baaf

RUN apt-get update \
    && apt-get install --yes --no-install-recommends bash \
    && rm -rf /var/lib/apt/lists/* \
    && python -m pip install --no-cache-dir uv==0.8.17

WORKDIR /tmp
CMD ["bash"]
