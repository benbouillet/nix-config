FROM docker.io/library/python:3.15.0-slim-bookworm@sha256:45a67c38107c44863d8f1a1994857b20e2f27014c50a84b096d1d8a71667e21a

RUN apt-get update \
    && apt-get install --yes --no-install-recommends bash \
    && rm -rf /var/lib/apt/lists/* \
    && python -m pip install --no-cache-dir uv==0.8.17

WORKDIR /tmp
CMD ["bash"]
