# using ubuntu LTS version
# from https://luis-sena.medium.com/creating-the-perfect-python-dockerfile-51bdec41f1c8

# using ubuntu LTS version
FROM ubuntu:20.04

RUN apt-get update && apt-get install --no-install-recommends -y python3.8-dev \
    python3.8-venv python3-pip python3-wheel build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# create and activate virtual environment
RUN python3.8 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Poetry
RUN python3 -m pip install pipx && \ 
    python3 -m pipx ensurepath && \
    pipx install poetry && \
    pipx ensurepath

# Set up environment variables for Poetry
ENV PATH="$PATH:/root/.local/bin"
ENV POETRY_HOME="/root/.poetry"

# export path
ENV PATH="$PATH:/root/.local/share/pipx/venvs/poetry/bin/"

# Install Pandas and Keras in a virtual environment using Poetry
WORKDIR /app

# Copy only the pyproject.toml and poetry.lock files initially to leverage Docker cache
COPY pyproject.toml ./

# upgrade pip
RUN pip install --upgrade pip setuptools wheel

# Copy the rest of the application code
# COPY . .
# not needed because we are mounting

# append Python module dir to Path
RUN PATH="${PATH}:/app/modules"

# Install dependencies
RUN poetry install --no-root --no-cache -vvv

# Set the default command to run the application
#CMD ["python", "framepool_annotate.py"]

# Expose port 8888 for Jupyter
EXPOSE 8080

# Command to run Jupyter notebook
CMD ["poetry", "run", "jupyter-notebook", "--ip=0.0.0.0", "--port=8080", "--no-browser", "--allow-root"]
