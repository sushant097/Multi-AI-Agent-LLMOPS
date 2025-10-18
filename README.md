

# 🧠 MULTI AI AGENT PROJECT — LLMOPS PIPELINE

A compact, **multi-agent LLMOps** project demonstrating how to build, test, analyze, and deploy an AI assistant using:

* CI/CD with **Jenkins**
* Code quality analysis via **SonarQube**
* Containerization using **Docker**
* Deployment to **AWS ECS (Fargate)**

This README provides a clean, end-to-end guide — from local setup to production deployment.

---

## 📘 Table of Contents

1. [About](#about)
2. [Tools & Tech Stack](#tools--tech-stack)
3. [Repository Layout](#repository-layout)
4. [Local Setup](#local-setup)
5. [WSL & Docker Setup (Windows)](#wsl--docker-setup-windows)
6. [CI/CD with Jenkins](#cicd-with-jenkins)
7. [SonarQube Integration](#sonarqube-integration)
8. [AWS ECR & ECS Deployment](#aws-ecr--ecs-deployment)
9. [Environment Variables](#environment-variables)
10. [Development Notes](#development-notes)
11. [License](#license)

---

## 🔍 About

This repository demonstrates how to orchestrate **multiple AI agent components** and ship them through a complete CI/CD pipeline.

Includes:

* Python backend (`app/backend/`)
* AI agent logic (`core/ai_agent.py`)
* Basic frontend utilities (`frontend/ui.py`)
* Jenkins pipeline configuration (`Jenkinsfile`)
* Deployment to AWS ECS (Fargate) via ECR

---

## 🧩 Tools & Tech Stack

* **Python 3.x**
* **Docker** (containers for app, Jenkins, SonarQube)
* **Jenkins** — CI/CD pipeline
* **SonarQube** — static analysis
* **AWS ECR** — container registry
* **AWS ECS (Fargate)** — managed deployment
* **GitHub** — source and pipeline trigger
* Optional: **WSL (Windows)** or native Docker on macOS/Linux

---

## 📂 Repository Layout

```
Multi-AI-Agent-LLMOPS/
│
├── app/
│   ├── main.py              # Entry point
│   └── backend/api.py       # Backend routes
│
├── core/
│   └── ai_agent.py          # Agent logic
│
├── frontend/
│   └── ui.py                # UI helper scripts
│
├── custom_jenkins/
│   └── Dockerfile           # Jenkins setup image
│
├── Jenkinsfile              # Pipeline definition
├── requirements.txt
└── setup.py
```

---

## 💻 Local Setup

### 1. Clone Repository

```bash
git clone https://github.com/sushant097/Multi-AI-Agent-LLMOPS.git
cd Multi-AI-Agent-LLMOPS
```

### 2. Create Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate   # (macOS/Linux)
# or
venv\Scripts\activate      # (Windows)
```

### 3. Install Dependencies

```bash
pip install -e .
```

### 4. Run Application

```bash
python app/main.py
```

You should now see the app running locally (port may vary by implementation).

---

## 🐧 WSL & Docker Setup (Only Windows)

**If your local setup has MacOs/Linux then install normally as provided in docker website.**

> Skip this section if using macOS or Linux — Docker runs natively there.

### Step 1 — Enable WSL and Install Ubuntu

```powershell
wsl --install
wsl --update
```

Then install **Ubuntu 22.04 LTS** from the Microsoft Store.

### Step 2 — Install Docker Engine in WSL

```bash
sudo apt update
sudo apt install ca-certificates curl gnupg lsb-release -y
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo usermod -aG docker $USER
```

Restart the terminal, then verify:

```bash
docker --version
```

---

## 🚀 CI/CD with Jenkins

### Step 1 — Build and Run Jenkins in Docker

```bash
docker build -t jenkins-dind custom_jenkins/
docker run -d --name jenkins-dind \
  --privileged \
  -p 8080:8080 -p 50000:50000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v jenkins_home:/var/jenkins_home \
  jenkins-dind
```

Retrieve Jenkins password:

```bash
docker logs jenkins-dind
```

Access Jenkins at:

```
http://localhost:8080
```

### Step 2 — Install Python inside Jenkins

```bash
docker exec -u root -it jenkins-dind bash
apt update -y && apt install -y python3 python3-pip
ln -s /usr/bin/python3 /usr/bin/python || true
exit
docker restart jenkins-dind
```

### Step 3 — Connect GitHub

1. Generate GitHub PAT (scopes: `repo`, `repo_hook`).
2. Add in Jenkins → **Manage Credentials → Global → Add Credentials** (ID: `github-token`).
3. Create a pipeline job → link your repo → select credential → build pipeline.

---

## 📊 SonarQube Integration

### Step 1 — Run SonarQube

```bash
sysctl -w vm.max_map_count=524288
ulimit -n 131072
docker run -d --name sonarqube-dind -p 9000:9000 sonarqube
```

Access: `http://localhost:9000` (default: admin/admin)

### Step 2 — Configure Jenkins

1. Install **SonarScanner** + **SonarQualityGates** plugins.
2. Add **SonarQube token** as secret text credential (ID: `sonarqube-token`).
3. Configure Jenkins → System → **SonarQube Servers**:

   * Name: `SonarQube`
   * URL: `http://sonarqube-dind:9000`
4. Connect both containers:

```bash
docker network create dind-network
docker network connect dind-network jenkins-dind
docker network connect dind-network sonarqube-dind
```

### Step 3 — Jenkinsfile Stage

The `Jenkinsfile` already includes a `sonarqube` stage for analysis.

---

## ☁️ AWS ECR & ECS Deployment

### Step 1 — Setup AWS Credentials in Jenkins

1. Create IAM user with:

   * `AmazonEC2ContainerRegistryFullAccess`
   * `AmazonEC2ContainerServiceFullAccess`
2. Add in Jenkins Credentials:

   * ID: `aws-credentials`
   * Access Key & Secret

### Step 2 — Install AWS CLI in Jenkins Container

```bash
docker exec -u root -it jenkins-dind bash
apt update -y && apt install -y unzip curl
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && ./aws/install && aws --version
exit
```

### Step 3 — Create and Push Image to ECR

```bash
# In Jenkinsfile (already configured)
# AWS ECR build & push stages
```

Trigger pipeline → image is built and pushed to ECR.

### Step 4 — Deploy to AWS ECS (Fargate)

1. Create ECS Cluster → **Fargate**
2. Create Task Definition → add container using ECR image URI → Port 8501
3. Create Service → enable Public IP
4. Open security group → inbound TCP 8501 → `0.0.0.0/0`
5. Visit `http://<PublicIP>:8501` to verify.

---

## 🔐 Environment Variables

Add these in your ECS **Task Definition** under Container → Environment Variables:

```
GROQ_API_KEY = gsk_...
TAVILY_API_KEY = tvly-dev-...
```

---

## 🧪 Development Notes

* Package editable: `pip install -e .`
* Test locally via `app/main.py`
* CI pipeline covers build → test → analyze → deploy.

---

## 📜 License

This project is open-source under the **MIT License**.