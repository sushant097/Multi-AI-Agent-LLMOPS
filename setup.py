from setuptools import setup, find_packages


with open("requirements.txt") as f:
    requirements = f.read().splitlines()


setup(
    name="multi_ai_agent_llmops",
    version="0.1.0",
    author="Sushant",
    description="A Multi AI Agent LLMOPS project",
    packages=find_packages(),
    install_requires=requirements,
    python_requires='>=3.8',
)