# Stage 1: fetch a matching-arch AWS CLI (multi-arch, from public ECR)
FROM amazon/aws-cli AS awscli

# Stage 2: your Jenkins image
FROM jenkins/jenkins:lts

USER root

# Docker CLI & friends (your existing bits)
RUN apt-get update && apt-get install -y ca-certificates curl gnupg && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg \
      | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    . /etc/os-release && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/debian ${VERSION_CODENAME} stable" \
      > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli docker-buildx-plugin docker-compose-plugin unzip && \
    rm -rf /var/lib/apt/lists/*

# Copy AWS CLI from stage 1
COPY --from=awscli /usr/local/aws-cli/ /usr/local/aws-cli/
RUN ln -sf /usr/local/aws-cli/v2/current/bin/aws /usr/local/bin/aws && aws --version

# Your original Jenkins user + DinD volume
RUN groupadd -f docker && usermod -aG docker jenkins
RUN mkdir -p /var/lib/docker
VOLUME /var/lib/docker

USER jenkins
