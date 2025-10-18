# MULTI AI AGENT PROJECT DOCUMENTATION


## 🛠️ Setup Instructions

### 1. Clone the Repository
 # MULTI AI AGENT PROJECT

 A compact, multi-agent LLM Ops project that demonstrates building, testing, and deploying an AI assistant application using CI/CD (Jenkins), code-quality analysis (SonarQube), containerization (Docker), and deployment to AWS ECS Fargate.

 This README is a polished, step-by-step rewrite of the original documentation. All existing deployment instructions were preserved — reorganized and clarified for easier follow-through.

 ## Table of contents
 - About
 - Tools & stack
 - Repository layout
 - Quickstart: local setup
 - Detailed deployment (Jenkins, SonarQube, AWS ECR, ECS / Fargate)
 - Environment variables
 - Development notes
 - Contributing
 - License


 ## About

 This repository contains a demonstration project for orchestrating multiple AI agent components and shipping them through a CI/CD pipeline. It includes:
 - A minimal Python application (entrypoint: `app/main.py`)
 - A small backend API module under `app/backend` for serving or integrating the agents
 - Core agent logic in `core/ai_agent.py`
 - A basic frontend utility in `frontend/ui.py`
 - CI/CD helpers and a `Jenkinsfile` used by the project's Jenkins pipeline

 The intent is educational: to show how to wire testing, static analysis, container builds, registry pushes, and automated deployment to AWS Fargate.


 ## Tools and technologies used
 - Python 3.x
 - Docker (build images for Jenkins, SonarQube, application images)
 - Jenkins (running in Docker) for CI/CD
 - SonarQube for static analysis / quality gates
 - AWS ECR for storing Docker images
 - AWS ECS with Fargate for container deployment
 - GitHub as source code host (pipeline triggers)
 - Optional: WSL on Windows for Docker-in-Docker workflows (original instructions reference WSL; on macOS/Linux use native Docker)


 ## Repository layout (summary)
 - `app/` — application entrypoint and backend modules
   - `app/main.py` — run the application locally
   - `app/backend/api.py` — backend API glue
 - `core/` — core AI agent code (e.g. `ai_agent.py`)
 - `frontend/` — UI helpers (e.g. `ui.py`)
 - `custom_jenkins/` — Jenkins Dockerfile and supporting artifacts used to launch a Jenkins instance
 - `Jenkinsfile` — pipeline skeleton used by Jenkins
 - `requirements.txt`, `setup.py` — packaging and dependencies


 ## Quickstart — run locally

 1) Clone the repository
 ```bash
 git clone https://github.com/sushant097/Multi-AI-Agent-LLMOPS.git
 cd Multi-AI-Agent-LLMOPS
 ```

 2) Create and activate a Python virtual environment
 - macOS / Linux
 ```bash
 python3 -m venv venv
 source venv/bin/activate
 ```
 - (Note) The original instructions included a Windows-style activation path; the macOS/Linux path above is correct for most UNIX-like shells.

 3) Install the package and dependencies
 ```bash
 pip install -e .
 ```

 4) Run the application
 ```bash
 python app/main.py
 ```

 You should now see the app listening or printing logs depending on `app/main.py` implementation.


 ## Detailed deployment (preserved step-by-step instructions)

 The project provides a step-by-step deployment path covering:
 1. Running Jenkins inside Docker (custom Jenkins image in `custom_jenkins/`)
 2. Integrating Jenkins with GitHub (personal access token)
 3. Adding SonarQube static analysis in the pipeline
 4. Building and pushing Docker images to AWS ECR
 5. Deploying to AWS ECS Fargate and automating the final step from Jenkins

 The original README contains explicit commands and sequential steps — all of those are preserved below with minimal edits for clarity. If you already cloned the repo, many files (like `custom_jenkins/Dockerfile` and `Jenkinsfile`) already exist.


 ### Pre-note about environment
 - The original deployment steps reference running Docker and Jenkins inside WSL on Windows. On macOS you don't need WSL; run Docker and the commands directly in your macOS terminal. Replace `ip addr show eth0` with the equivalent if you're using Docker on a remote host.


 ### Step 1 — Jenkins setup (Docker)

 1. (Optional) Confirm `custom_jenkins/` and its `Dockerfile` exist in the repo (they are present if you cloned).

 2. Build the Jenkins Docker image (run from the repository root where `custom_jenkins/Dockerfile` is located):
 ```bash
 docker build -t jenkins-dind custom_jenkins/
 ```

 3. Run the Jenkins container:
 ```bash
 docker run -d --name jenkins-dind \
   --privileged \
   -p 8080:8080 -p 50000:50000 \
   -v /var/run/docker.sock:/var/run/docker.sock \
   -v jenkins_home:/var/jenkins_home \
   jenkins-dind
 ```

 4. Verify it is running:
 ```bash
 docker ps
 ```

 5. Retrieve logs (initial admin password is printed on first start):
 ```bash
 docker logs jenkins-dind
 ```

 6. (If needed) Install Python inside the Jenkins container to run Python-based pipeline steps:
 ```bash
 docker exec -u root -it jenkins-dind bash
 apt update -y
 apt install -y python3 python3-pip
 ln -s /usr/bin/python3 /usr/bin/python || true
 exit
 ```

 7. Restart Jenkins to pick up changes:
 ```bash
 docker restart jenkins-dind
 ```

 8. Access Jenkins in the browser at:
 ```
 http://<HOST_IP>:8080
 ```
 Replace `<HOST_IP>` with your host IP (on macOS typically `localhost`) or the WSL IP if using WSL.


 ### Step 2 — GitHub integration in Jenkins

 1. Generate a GitHub personal access token (classic) with `repo` and `repo_hook` scopes.
 2. In Jenkins, add the token as credentials: Manage Jenkins → Manage Credentials → Global → Add Credentials. Use the token as the password/secret and provide an ID like `github-token`.
 3. Create a new Pipeline job in Jenkins and configure the SCM/checkout step to use your repository URL and the `github-token` credential. The original README suggests generating the `checkout` pipeline snippet from Jenkins Pipeline Syntax and adding it to `Jenkinsfile`.
 4. Add the `Jenkinsfile` to the repo (it's included if you cloned). Initially keep the first checkout stage; additional stages (build, test, sonar, push, deploy) are commented out until you enable them.


 ### Step 3 — SonarQube integration

 1. (System setup) Run system tuning commands on the host if required by SonarQube:
 ```bash
 sysctl -w vm.max_map_count=524288
 sysctl -w fs.file-max=131072
 ulimit -n 131072
 ulimit -u 8192
 ```

 2. Start SonarQube (example minimal run; adapt to your environment):
 ```bash
 docker run -d --name sonarqube-dind \
   -p 9000:9000 \
   -e SONARQUBE_JDBC_URL=jdbc:postgresql://localhost/sonar \
   sonarqube
 ```

 3. Verify SonarQube: open `http://<HOST_IP>:9000` and login with `admin`/`admin` (first login may prompt password change).
 4. Install Jenkins plugins: SonarScanner and SonarQualityGates (Manage Jenkins → Manage Plugins) and restart Jenkins.
 5. Create a SonarQube token (My Account → Security → Generate Token) and add it to Jenkins as a secret text credential with ID `sonarqube-token`.
 6. Configure SonarQube server in Jenkins (Manage Jenkins → Configure System → SonarQube Servers) and set SonarQube Scanner to install automatically.
 7. Add a SonarQube stage to `Jenkinsfile` (the repo includes an example). Connect Jenkins and SonarQube either via network (shared Docker network) or by using the container name as host: `http://sonarqube-dind:9000`.
 8. Create a Docker network and connect both containers if desired:
 ```bash
 docker network create dind-network
 docker network connect dind-network jenkins-dind
 docker network connect dind-network sonarqube-dind
 ```


 ### Step 4 — AWS: build & push Docker images to ECR

 1. In Jenkins, install the AWS SDK and AWS Credentials plugins, then restart Jenkins.
 2. Create an IAM user with the `AmazonEC2ContainerRegistryFullAccess` policy, then create an access key and secret.
 3. In Jenkins Credentials, create AWS credentials with ID `aws-credentials` using the access key and secret.
 4. (Optional) Install AWS CLI inside the Jenkins container:
 ```bash
 docker exec -u root -it jenkins-dind bash
 apt update -y
 apt install -y unzip curl
 curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
 unzip awscliv2.zip
 ./aws/install
 aws --version
 exit
 ```

 5. Create an ECR repository in the AWS Console and note the repository URI.
 6. Add build-and-push stages to your `Jenkinsfile` (the repository includes a sample). The sample pipeline will authenticate with ECR, build the Docker image, tag it with the ECR URI, and push it.


 ### Step 5 — Deploy to AWS ECS (Fargate)

 1. Create an ECS cluster (Fargate) in the AWS console.
 2. Create a task definition (Fargate) and add a container using the ECR image URI. Map container port 8501 to the host (or use load balancer as preferred).
 3. Create an ECS Service using the Task Definition and enable a public IP (or use a load balancer).
 4. Adjust security groups to allow inbound TCP on port 8501 from the internet (0.0.0.0/0) if you want public access.
 5. In Jenkins, add a deployment stage (or use the AWS CLI / SDK) to update the ECS service to the new image after the push step. The original README describes granting `AmazonEC2ContainerServiceFullAccess` to the IAM user used by Jenkins for this purpose.
 6. Verify the service's task public IP and visit `http://<PublicIP>:8501` to confirm the app is reachable.


 ## Environment variables
 The README mentions adding API keys as environment variables in the ECS task definition. Two example variables used by the project are:
 - GROQ_API_KEY
 - TAVILY_API_KEY

 Add them in the Task Definition's container environment variables section when you configure ECS.


 ## Development notes and testing
 - The project is packaged with `setup.py` and declares dependencies in `requirements.txt`. Use `pip install -e .` to install the package in editable mode.
 - The `app/main.py` file is the local development entrypoint. For CI, the Jenkins pipeline exercises build/test/scan stages.


 ## Contributing
 - Fork the repo, create branches for features or fixes, and submit pull requests. Keep changes small and include tests where relevant.
 - Update `Jenkinsfile` carefully; the repo contains a pipeline template with the checkout stage enabled and remaining stages commented out.


 ## License
 See `PKG-INFO` and `SOURCES.txt` in the `multi_ai_agent_llmops.egg-info/` directory for packaging metadata. Add a LICENSE file if you want a project-wide license applied.


 ## Summary of changes in this README
 - Reorganized and clarified the original README with the exact deployment steps preserved.
 - Kept all step-by-step commands and guidance so you can follow the original CI/CD + AWS flow.

 If you want, I can now:
 - Run a quick smoke test by launching `python app/main.py` (I can run it here and report any errors), or
 - Update the `Jenkinsfile` to enable a full multi-stage pipeline example (build → test → sonar → push → deploy).

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
```

4. Verify the installation:

```bash
aws --version
```

5. Exit the container:

```bash
exit
```

---

### 5. Create an ECR Repository in AWS

1. Go to **AWS Console** → **ECR (Elastic Container Registry)** → **Create Repository**.
2. Name the repository (e.g., `my-repository`).
3. Set up the repository as required and save the repository URL for later use.

---

### 6. Add Build and Push Docker Image to ECR Stage in Jenkinsfile

Already done if clone just change according to your repo name..

### 7. Push the Changes to GitHub

Push the updated `Jenkinsfile` to your GitHub repository to trigger the pipeline.

---

### 8. Run the Jenkins Pipeline

1. Go to the **Jenkins Dashboard**.
2. Click on **Build Now** for your pipeline.
3. The pipeline will execute, building the Docker image and pushing it to **Amazon ECR**.

---

✅ **Congratulations!** Your Docker image has been successfully built and pushed to Amazon ECR using Jenkins.


## Step 5 : Final Deployment Stage with AWS ECS and Jenkins

Follow these steps to deploy your app to **AWS ECS Fargate** using Jenkins and automate the deployment process.

### 1. Create ECS Cluster and Task Definition

1. **Create ECS Cluster**:
   - Go to **ECS** → **Clusters** → **Create Cluster**.
   - Give your cluster a name and select **Fargate**.
   - Click **Create** to create the cluster.

2. **Create ECS Task Definition**:
   - Go to **ECS** → **Task Definitions** → **Create new Task Definition**.
   - Select **Fargate** as the launch type.
   - Give the task definition a name (e.g., `llmops-task`).

3. **Container Configuration**:
   - Under **Container details**, give the container a name and use the **ECR URI** (the Docker image URL from your ECR repository).
   - In **Port Mapping**, use the following configuration:
     - **Port:** 8501
     - **Protocol:** TCP
     - **None:** leave it as default.
   
4. **Create Task Definition**:
   - Click **Create** to create the task definition.

---

### 2. Create ECS Service

1. Go to **ECS** → **Clusters** → Your cluster.
2. Click **Create Service**.
3. Select your **Task Definition** (`llmops-task`).
4. Select **Fargate** for launch type (this should be the default option).
5. Give the service a name (e.g., `llmops-service`).
6. Under **Networking**, select:
   - **Public IP**: Allow a public IP.
7. Click **Create** and wait for a few minutes for the service to be deployed.

---

### 3. Configure Security Group for Public Access

1. Search for **Security Groups** in the AWS console.
2. Select the **Default security group**.
3. Go to the **Inbound Rules** and click **Edit inbound rules**.
4. Add a new **Custom TCP rule** with the following details:
   - **Port range:** 8501
   - **Source:** 0.0.0.0/0 (allow access from all IPs).
5. Save the rules.

---

### 4. Check the Deployment

1. After the ECS service has been deployed (this may take a few minutes), go to your ECS cluster.
2. Open the **Tasks** tab and copy the **Public IP** of your task.
3. Open a browser and visit: `http://<PublicIP>:8501`.
   - You should see your app running.

---

### 5. Automate Deployment with Jenkins

1. **Add ECS Full Access Policy** to the IAM user:
   - Go to **IAM** → **Users** → **Your IAM User** → **Attach Policies**.
   - Attach the **AmazonEC2ContainerServiceFullAccess** policy to the IAM user.

2. **Update Jenkinsfile for ECS Deployment**:
   - Add the deployment stage to your `Jenkinsfile`. This will automate the deployment of your Docker container to AWS ECS.

3. Push the updated code to GitHub.

---

### 6. Build Jenkins Pipeline

1. Go to **Jenkins Dashboard**.
2. Click on **Build Now** to trigger the Jenkins pipeline.
3. The pipeline will run, and you will see the task in the **ECS Service** go to **In Progress**.
4. Once the pipeline is complete, your service will be **Running** again.

---

### 7. Verify the Deployment

1. Open the ECS cluster and check the **Task** status.
2. After the task is successfully deployed, visit your app at `http://<PublicIP>:8501` to ensure it is working.

---

### 8. Option 1: Use AWS ECS Environment Variables (Simplest)

1. Go to your ECS **Task Definition** in the AWS Console.
2. Edit the container definition.
3. Scroll to the **Environment Variables** section.
4. Add the following environment variables:
   - **GROQ_API_KEY:** `gsk_...`
   - **TAVILY_API_KEY:** `tvly-dev-...`
5. Save the changes and **redeploy the task**.

---

### ✅ **Deployment Complete**

Your app is now deployed to AWS ECS Fargate. You can access it via the public IP at port `8501`. The deployment process has been automated using Jenkins, and the app is now live.







