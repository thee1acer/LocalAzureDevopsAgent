# Local Azure DevOps Agent

## Description

This project implements a local Azure DevOps agent that replicates the behavior of a cloud-hosted agent. It allows you to run Azure DevOps pipelines locally, enabling faster testing and development without relying on cloud infrastructure.

The solution uses a Docker container running a Linux image of the Azure DevOps agent, sourced from Microsoft's [Azure Pipelines Agent Releases](https://github.com/microsoft/azure-pipelines-agent/releases). This approach is perfect for testing local and development builds before creating pull requests or merging to master branches.

The initial implementation was developed in Azure DevOps. You can view the project here: [Local Azure DevOps Agent on Azure DevOps](https://dev.azure.com/32302916/Self-Hosted%20Azure%20Devops%20Agent)

## Features

- **Run Azure DevOps Pipelines Locally**:  
  Replicates the behavior of a cloud-hosted Azure DevOps agent, enabling you to test pipelines locally without relying on cloud execution times. This is ideal for testing, debugging, and development.
- **Trigger Pipelines on Feature Branches**:  
  Automatically trigger pipeline runs for commits on feature branches (any branch except master). This allows for granular testing of new features or bug fixes before merging into the main codebase.

- **Flexible and Customizable Solution**:  
  The Docker container can be easily customized to use different images or configurations, providing flexibility for various environments or use cases.

- **Scalable for Various Environments**:  
  Suitable for small projects or large enterprise setups, the solution scales to different environments and teams, ensuring flexibility in CI/CD workflows.

- **Seamless Integration with Azure DevOps**:  
  The agent integrates smoothly with Azure DevOps, minimizing setup complexity and enhancing your CI/CD pipelines.

## Table of Contents

- [Installation and Usage](#installation)
- [Contributing](#contributing)
- [Acknowledgments](#acknowledgments)

## Installation

### Prerequisites

- **Git**: To clone the repository and interact with source control.
- **Docker**: To run the agent in a Docker container.
- **VS Code (Recommended)**: For easy project management (optional).
- **Azure DevOps Account and Project**: Necessary for integrating with your DevOps project.
- **Personal Access Token (PAT)**: Required for the agent to authenticate with your Azure DevOps project.
- **Agent Pool Setup**: To assign the agent to a custom pool.

### Setup Steps (for adding the local agent to your Azure DevOps repository)

1. **Clone the Repository**  
   Clone the repository:  
   `git clone https://github.com/thee1acer/LocalAzureDevopsAgent.git`  
   _(Note: This is optional if you already have the repository.)_

2. **Set Up Azure DevOps Pool and Personal Access Token (PAT)**

   - **Agent Pool Setup**:  
     In your Azure DevOps project, navigate to **Project Settings > Agent Pools** and add a self-hosted agent. Follow the [Azure DevOps Agent Setup Documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/windows-agent?view=azure-devops&tabs=IP-V4). Keep track of the agent pool name, as it will be needed later.

   - **Create Personal Access Token (PAT)**:  
     Go to **User Settings** > **Personal Access Tokens** > **Add New Token**. Assign the appropriate rights and **copy the generated token** (it will not be saved). Keep it secure for later use.

   - **Configure `.env` File**:  
     In the root of your project, create a `.env` file with the following fields:
     ```bash
     AZURE_PERSONAL_TOKEN="your_personal_access_token"
     AZURE_AGENT_POOL="Local Azure Agent" # Use the name of the agent pool created
     AZURE_COMPANY_URL="https://dev.azure.com/your_company" # Replace with your Azure DevOps organization URL
     ```

3. **Docker Container Setup**

   - Copy the Docker container definition into your `docker-compose.yml` file.
   - Copy the `docker-scripts` folder into the root of your project. Ensure the scripts use Unix line endings (check with Notepad++).
   - In your terminal, run:  
     `docker-compose run --service-ports ubuntu-agent`  
     Accept the agent terms and conditions when prompted. When asked for the authentication type, press **Enter** to select **PAT**. Paste your PAT and wait for the connection to complete.

4. **Trigger Pipelines on Commits**  
   To trigger pipelines on commits, modify your pipeline’s configuration as follows:

   - **Update the Build Trigger**:
     Add the following to your pipeline YAML file to trigger builds on feature branches:

     ```yaml
     trigger:
       branches:
         include:
           - master
           - "*"
     ```

   - **Dynamically Select Agent Pool**:
     Update the pipeline YAML to dynamically choose the agent pool based on the branch name:

     ```yaml
     variables:
       poolName: $[iif(eq(variables['Build.SourceBranchName'], 'master'), 'Azure Pipelines', 'Local Azure Agent')]

     pool:
       name: $(poolName)
     ```

     This setup ensures that the pipeline runs on the local agent for feature branches and the Azure Pipelines agent for the master branch.

5. **Pipeline Execution**  
   Once set up, the pipeline will automatically trigger and run the local Azure DevOps agent for commits on local branches.


** See **
![image](https://github.com/user-attachments/assets/955e1d0d-08c8-4b22-a07e-2fdf066fea53)

![image](https://github.com/user-attachments/assets/eb6f592c-1079-4688-8323-763b7ae51613)

![image](https://github.com/user-attachments/assets/31ddba0a-1f95-44d4-9c60-6aa22db24681)

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

- [Microsoft Azure Agent Images](https://github.com/microsoft/azure-pipelines-agent/releases)
