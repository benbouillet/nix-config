FROM docker.io/library/python:3.15.0-slim-bookworm@sha256:5d433483bdbe83b29917e94d48ad062df40f1bd93ecebfd5d4bff132a6a8de15

RUN apt-get update \
    && apt-get install --yes --no-install-recommends bash \
    && rm -rf /var/lib/apt/lists/* \
    && python -m pip install --no-cache-dir uv==0.8.17

WORKDIR /tmp
CMD ["bash"]
