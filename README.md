
# Local Azure Devops Agent

## Description

> This project is a local Azure DevOps agent that replicates the behavior of a cloud-hosted Azure DevOps agent, allowing you to run pipelines locally for testing and development purposes.
The solution is implemented using a Docker container that runs a Linux image of the Azure DevOps agent. The agent image is sourced from Microsoft's [Azure Pipelines Agent Releases](https://github.com/microsoft/azure-pipelines-agent/releases).
The initial implementation of this solution was created in Azure DevOps. You can view the project here: [Local Azure DevOps Agent on Azure DevOps](https://dev.azure.com/32302916/Local%20Azure%20Devops%20Agent).

## Features

- Run Azure DevOps Pipelines Locally:
  > Replicate the behavior of a cloud-hosted Azure DevOps agent on your local machine, allowing you to run and test pipelines locally without needing to rely on cloud infrastructure. This is ideal for testing, debugging, and developing without waiting for cloud execution times.
- Trigger Pipelines on Feature Branches:
  > Automatically trigger pipeline runs for commits on feature branches (any branch except the master branch), enabling more granular testing of new features or bug fixes before merging them into the main codebase.
- Flexible and Customizable Solution:
  > The Docker container can be easily adjusted to use different images or configurations, allowing you to tailor the solution for specific environments or use cases.
- Scalable for Various Environments:
  > The solution can be scaled to different environments or teams, making it suitable for both small-scale projects and larger enterprise setups, ensuring flexibility in CI/CD workflows.
- Seamless Integration with Azure DevOps:
  > Direct integration with Azure DevOps allows for smooth connectivity and operation within your existing DevOps pipelines, minimizing setup complexity and streamlining the process.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [Acknowledgments](#acknowledgments)

## Installation

### Prerequisites

- ```Git```: To clone repo and interact with source control.
- ```Docker```: To run the agent that is deployed in a docker container.
- ```VS Code (Recommended, Not Required)```
- ```Azure DevOps Account and Project```:  This is going to be used within a project
- ```Personal Access Token (will show how to set this up)```: So that the agent can interact with the cloud environment
- ```Agent Pool Setup```: This is to just ensure that our agent is going to run on a custom pool.

### Steps (assuming you want to add this local agent to your existing azure devops repo)

1. ```Clone the repository```: git clone https://github.com/thee1acer/LocalAzureDevopsAgent.git (not necessary)
2. ```Setting up Azure Devops Pool and Personal access token (PAT) and configuration file```:
   - Setting up Azure Devops Pool:
     > In your Azure Devops Project navigate to Project Settings > Agent Pools ![image](https://github.com/user-attachments/assets/a1f4ddb5-9281-4b9f-848b-205b0077739c) and add self hosted agent, see [Azure Devops Self Hosted Agent'](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/windows-agent?view=azure-devops&tabs=IP-V4) We are going to need this name so keep it safe.

   - Personal Access Token (PAT)
     > In your Azure Devops Project naviagte to user settings ![image](https://github.com/user-attachments/assets/2655bf97-6ea3-4a23-954a-c5857c4ef2a0) and navogate to ```personal access tokens``` >> Add new token >>  Assign rights >> Copy token generated because it is not saved and keep it safe

   - Configuration file:
      > In your project root folder add a .env file that has fields:
      ```bash
        # Here is an example
        AZURE_PERSONAL_TOKEN="---------------------"
        AZURE_AGENT_POOL="Local Azure Agent" #depends on what you called the agent pool you created
        AZURE_COMPANY_URL="https://dev.azure.com/32302916" # this is just a link to you devops project not the repo
      ```
4. ```Docker Container Setup```:
   - Copy docker container definition into your docker-compose yml file.
   
   - Copy docker-scripts folder into the root of your project. Ensure that the scripts have unix line endings. Easiest way to check this is if you open a .sh script in notepad++ it should show this at the bottom right corner ![image](https://github.com/user-attachments/assets/7e2843f6-5b94-4957-b9db-5b3fcef1ea98).

   - In your terminal you should run ```docker-compose up ubuntu agent ```. If prompted to accept terms and conditions of the agent enter 'Y'. If asked for type of authentication hit enter for PAT.
   - Enter PAT and wait for connection
5. ```Trigger pipeline on commits```:
   - For this step we need to change a small portion of our release pipeline.
     > For pipeline build trigger you need to add:
     
     ```bash
     trigger:
      branches:
       include:
         - master
         - "*"
     ```
     > For our pipeline to dynamically select the agent pool to run when trigger we need to set
     ```bash
       variables:
       poolName: $[iif(eq(variables['Build.SourceBranchName'], 'master'), 'Azure Pipelines', 'Local Azure Agent')]
     ```
3. Now the pipeline will be triggered and run the local azure agent whenever we commit on our local branches

---

## Usage


### Starting the devops agent

   ```bash
   docker-compose up ubuntu-agent
   ```

### Listening for jobs
  Once the agent is up and running it should look like this
  
  ![image](https://github.com/user-attachments/assets/da6e58e0-b3c3-4cac-abf9-d59a38a02c9c)
  
---

## Contributing

We welcome contributions to this project! To contribute:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes.
4. Commit your changes (`git commit -am 'Add new feature'`).
5. Push to your branch (`git push origin feature-branch`).
6. Create a pull request.

## Acknowledgments

- List any third-party resources, libraries, or tools that were used.


