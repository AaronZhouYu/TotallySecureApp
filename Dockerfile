# Use an official Ubuntu base image
FROM ubuntu:20.04

# Set environment variables to non-interactive (this prevents some prompts)
ENV DEBIAN_FRONTEND=noninteractive
# Update apt and install XZ Utils
RUN apt-get update && \
    apt-get install -y --no-install-recommends xz-utils=5.6.0 && \
    rm -rf /var/lib/apt/lists/*

# Example: Copy your project files into the Docker image
COPY ./myproject /usr/src/myproject

# Set the working directory to your project folder
WORKDIR /usr/src/myproject

# Optional: Default command to compress a project folder using XZ
CMD ["tar", "cf", "-", "./" | "xz", "-z", "-9", "-e", "-c", "-", ">","myproject.tar.xz"]

ENV WORKDIR /usr/src/app/
WORKDIR $WORKDIR
COPY package*.json $WORKDIR
RUN npm install --production --no-cache

FROM node:12-alpine
ENV USER node
ENV WORKDIR /home/$USER/app
WORKDIR $WORKDIR
ADD --from=0 /usr/src/app/node_modules node_modules
RUN chown $USER:$USER $WORKDIR
COPY --chown=node . $WORKDIR

EXPOSE 22

FROM python:3-slim-buster
WORKDIR /app
COPY hello.py /app
CMD [“python3”, “hello.py”]
