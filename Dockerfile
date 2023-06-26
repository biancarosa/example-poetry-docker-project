
FROM python:3.10.6-slim-buster as lumos-common-base

# https://docs.python.org/3/using/cmdline.html#envvar-PYTHONUNBUFFERED
# Python env vars
ENV PYTHONUNBUFFERED=1 \
    # https://docs.python.org/3/using/cmdline.html#envvar-PYTHONDONTWRITEBYTECODE
    PYTHONDONTWRITEBYTECODE=1 \
    # Pip env vars (https://pip.pypa.io/en/stable/user_guide/#environment-variables)
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    # Poetry env vars (https://python-poetry.org/docs/configuration/#using-environment-variables)
    POETRY_VERSION=1.4.0  \
    POETRY_NO_INTERACTION=1

RUN pip install --no-cache-dir "poetry==$POETRY_VERSION"

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

RUN poetry config virtualenvs.create false

RUN apt-get update && apt-get install --no-install-recommends -y \
    cmake \
    g++ \
    build-essential \
    libgomp1
RUN ldconfig
RUN apt-get clean && apt-get autoclean && apt-get autoremove

# we need to copy __init__.py so that lumos_ml is technically a module,
# because we haven't copied over the actual code yet
COPY poetry.lock pyproject.toml /

RUN poetry --no-ansi install --without=dev --no-root && rm -rf $POETRY_CACHE_DIR

