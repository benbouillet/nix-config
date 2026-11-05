FROM docker.io/library/python:3.15.2-slim-bookworm@sha256:6cae5760197a96ea5d0a41ae2e045733c351d605c61148dd030aafdf4919e33a

RUN apt-get update \
    && apt-get install --yes --no-install-recommends bash \
    && rm -rf /var/lib/apt/lists/* \
    && python -m pip install --no-cache-dir uv==0.8.17

WORKDIR /tmp
CMD ["bash"]
