FROM docker.io/library/python:3.15.0-slim-bookworm@sha256:c1035719031463035de2f9b5ee86b0ab18842ddee18556ee89999f4b38a3c559

RUN apt-get update \
    && apt-get install --yes --no-install-recommends bash \
    && rm -rf /var/lib/apt/lists/* \
    && python -m pip install --no-cache-dir uv==0.8.17

WORKDIR /tmp
CMD ["bash"]
