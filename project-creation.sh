mkdir app
mkdir custom_jenkins
touch .gitignore
touch README.md
touch .env
touch requirements.txt
touch setup.py
touch Dockerfile
touch Jenkinsfile

# create directories and files inside app
touch app/__init__.py
touch app/main.py
mkdir app/config
touch app/config/__init__.py
touch app/config/settings.py
mkdir app/backend
touch app/backend/__init__.py
touch app/backend/api.py
mkdir app/common
touch app/common/__init__.py
touch app/common/custom_exception.py
touch app/common/logger.py
mkdir app/core
touch app/core/__init__.py
touch app/core/ai_agent.py
mkdir app/frontend
touch app/frontend/__init__.py
touch app/frontend/ui.py


touch custom_jenkins/Dockerfile