# using ubuntu LTS version
# from https://luis-sena.medium.com/creating-the-perfect-python-dockerfile-51bdec41f1c8

# using ubuntu LTS version
FROM ubuntu:20.04

# Configure Poetry
ENV POETRY_VERSION=1.8.3
ENV POETRY_HOME=/opt/poetry
ENV POETRY_VENV=/opt/poetry-venv
ENV POETRY_CACHE_DIR=/opt/.cache
ENV PIPX_BIN_DIR=/opt/.cache/virtualenvs/orfa-9TtSrW0h-py3.8/bin/

RUN apt-get update && apt-get install --no-install-recommends -y \
    python3.8-dev python3.8-venv python3-pip python3-wheel \
    build-essential libhdf5-dev pkg-config && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add `poetry` to PATH
ENV PATH="${PATH}:${POETRY_VENV}/bin"


# Install poetry separated from system interpreter
RUN python3 -m venv $POETRY_VENV \
    && . ${POETRY_VENV}/bin/activate \
    && $POETRY_VENV/bin/pip install -U pipx \
    && $POETRY_VENV/bin/pipx ensurepath \
    && $POETRY_VENV/bin/pipx install poetry==${POETRY_VERSION}

# Set up environment variables for Poetry
#ENV PATH="$PATH:/root/.local/bin"

# export path
ENV PATH="$PATH:/root/.local/share/pipx/venvs/poetry/bin/"

WORKDIR /app

# Copy only the pyproject.toml and poetry.lock files initially to leverage Docker cache
COPY pyproject.toml ./

# Copy the rest of the application code
COPY pyproject.toml .
COPY poetry.lock .
COPY framepool_annotate.py .
ADD modules /app/modules

# append Python module dir to Path
RUN PATH="${PATH}:/app/modules"

# Install dependencies
# RUN /opt/.cache/virtualenvs/orfa-9TtSrW0h-py3.8/bin/poetry install --no-root --no-cache -vvv
RUN poetry install --no-root --no-cache -vvv


# Set the default command to run the application
#CMD ["python", "framepool_annotate.py"]

# Expose port 8888 for Jupyter
EXPOSE 8080

# Command to run Jupyter notebook
CMD ["poetry", "run", "jupyter-notebook", "--ip=0.0.0.0", "--port=8080", "--no-browser", "--allow-root"]
