# using ubuntu LTS version
FROM ubuntu:20.04

# Configure Poetry
ENV POETRY_VERSION=1.8.3

RUN apt-get update && apt-get install --no-install-recommends -y \
    python3.8-dev python3.8-venv python3-pip python3-wheel \
    build-essential libhdf5-dev pkg-config && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install poetry separated from system interpreter
RUN pip install -U pipx \
    && pipx ensurepath \
    && pipx install poetry==${POETRY_VERSION}

# export path
ENV PATH="$PATH:/root/.local/share/pipx/venvs/poetry/bin/"

WORKDIR /app

# Copy the rest of the application code
COPY pyproject.toml .
COPY poetry.lock .
COPY framepool_annotate.py .
ADD modules /app/modules

# append Python module dir to Path
RUN PATH="${PATH}:/app/modules"

# Install dependencies
RUN poetry install --no-root --no-cache -vvv

# Expose port 8888 for Jupyter
EXPOSE 8080

# Command to run Jupyter notebook
CMD ["poetry", "run", "jupyter-notebook", "--ip=0.0.0.0", "--port=8080", "--no-browser", "--allow-root"]
