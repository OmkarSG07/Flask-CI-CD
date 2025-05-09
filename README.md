# Flask CI/CD Project

## Overview

This project is a basic Flask application set up with the intention of integrating various DevOps tools such as Docker, CI/CD pipelines, Terraform, Ansible, Docker, and monitoring with Prometheus and Grafana.


### 🔹 Step 1: Project Title & Summary

# 🚀 Flask CI/CD with Terraform, Ansible, Docker, Prometheus & Grafana

This project is a fully automated infrastructure and deployment pipeline for a **Flask-based web application** hosted on AWS. It uses **Terraform** for infrastructure provisioning, **Ansible** for configuration and deployment, and **Docker** for containerizing the application and monitoring tools like **Prometheus**, **Node Exporter**, and **Grafana**.

The goal is to showcase a complete DevOps workflow using open-source tools, with modular code and infrastructure-as-code best practices.

### 🔹 Step 2: 🛠️ Tech Stack 

- **Flask** – Lightweight Python web framework for building the application.
- **Docker** – Containerizes the application and monitoring tools.
- **Docker Compose** – Manages multi-container setup (Flask, Prometheus, Grafana, Node Exporter).
- **Terraform** – Provisions AWS infrastructure as code (EC2, VPC, Subnets, ALB, Security Groups, etc.).
- **Ansible** – Handles server provisioning, app deployment, and monitoring stack automation.
- **Prometheus** – Time-series database and monitoring system.
- **Node Exporter** – Collects host-level system metrics.
- **Grafana** – Visualizes metrics and builds monitoring dashboards.
- **AWS** – Cloud provider hosting the entire infrastructure.
- **GitHub** – Source code repository and version control.

### 🔹 Step 3: 📁 Project Structure

```
Flask-CI-CD/
├── ansible/
│   ├── inventory.ini               # Ansible inventory file
│   ├── playbook.yml                # Main playbook for Flask App deployment
│   └── monitoring/
│       ├── docker-compose.yml      # Docker Compose for Prometheus + Grafana monitoring stack
│       └── prometheus.yml          # Prometheus configuration file
├── terraform/
│   ├── main.tf                     # Terraform configuration file for creating infrastructure
│   ├── variables.tf                # Variables definition for Terraform
│   ├── outputs.tf                  # Outputs for Terraform configuration
│   ├── provider.tf                 # AWS provider setup for Terraform
│   ├── vpc.tf                      # VPC setup for Terraform
│   └── security_group.tf           # Security Group setup for EC2 instances and ALB
├── docker/
│   └── Dockerfile                  # Dockerfile for building the Flask application image
├── flask/
│   ├── app.py                      # Main Flask application
│   └── requirements.txt            # Python dependencies for the Flask app
├── .gitignore                      # Specifies files and folders that should be ignored by Git
├── README.md                       # Detailed project description and instructions
└── setup.sh                        # Setup script for environment preparation (if applicable)
```

### 🔹 Step 4: ✨ Features

- 🚀 **Fully Automated Infrastructure Setup**  
  Uses Terraform to provision an entire AWS environment including:
  - VPC with public subnets
  - Internet Gateway and Route Tables
  - Security Groups for EC2 and ALB
  - EC2 instance running Dockerized Flask app
  - Application Load Balancer for public access

- ⚙️ **End-to-End CI/CD with Ansible**  
  Ansible automates:
  - Flask app deployment
  - Docker & Docker Compose setup
  - Monitoring stack setup (Prometheus + Grafana + Node Exporter)

- 📈 **Integrated Monitoring**  
  - Prometheus to scrape metrics
  - Grafana dashboards for real-time visualization
  - Node Exporter for system-level metrics on EC2

- 📦 **Dockerized Flask Application**  
  - Lightweight and portable
  - Can be replaced or scaled with minimal configuration

- 🌐 **Highly Configurable & Modular**  
  - Infrastructure as Code (IaC)
  - Easy to update, scale, or adapt across different environments

- 🛠️ **Clean & Reusable Codebase**  
  - Well-structured and production-ready
  - Clear separation of concerns between Terraform, Ansible, and App layers

### 🔹 Step 5: ✅ Prerequisites

Before running this project, ensure you have the following installed and configured on your local machine:

### 🔧 Tools Required

- **Terraform** (v1.0+ recommended)  
  Infrastructure provisioning

- **Ansible** (v2.9+ recommended)  
  Configuration management & automation

- **AWS CLI** (configured with credentials)  
  For Terraform & Ansible to interact with AWS

- **SSH Key Pair**  
  Required to access EC2 instance  
  ⚠️ **Do not upload your `.pem` key to any public repository**

- **Docker** & **Docker Compose**  
  For local testing and service orchestration (optional)

### 🔐 AWS Resources Required

- An AWS account with:
  - EC2, VPC, IAM, and ALB access
  - A valid key pair created in the EC2 section

### 📦 Python Packages (if running Ansible from virtualenv)

```bash
pip install boto boto3
```
Ensure your SSH key (.pem file) path and other variables are correctly configured inside the inventory.ini and ansible.cfg files.

### Step 7: 🚀 How to Use

Follow these steps to provision infrastructure, deploy the app, and enable monitoring:

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/OmkarSG07/Flask-CI-CD.git
cd Flask-CI-CD
```
### 2️⃣ Provision Infrastructure using Terraform

```
cd terraform
terraform init
terraform apply
```
✅ This will set up the entire AWS infrastructure: VPC, Subnets, Internet Gateway, EC2 instance, and ALB.

### 3️⃣ Configure Inventory for Ansible

After Terraform finishes, get the public IP of the EC2 instance from the output and update the inventory file:

```
# ansible/inventory.ini
[flask_server]
your-ec2-public-ip ansible_user=ubuntu ansible_ssh_private_key_file=/path/to/your/key.pem
```

### 4️⃣ Run Ansible Playbook for App & Monitoring Setup

```
cd ../ansible
ansible-playbook -i inventory.ini playbook.yml
```
✅ This installs Docker, runs the Flask app, and sets up Prometheus + Grafana on the EC2 instance.

### 5️⃣ Access the Services

    Flask App: http://<EC2-Public-IP>:5000

    Grafana Dashboard: http://<EC2-Public-IP>:3000

        Default Login: admin / admin

    Prometheus: http://<EC2-Public-IP>:9090

    Node Exporter Metrics: http://<EC2-Public-IP>:9100/metrics


### 📊 Step 8: Monitoring Overview

This project integrates Prometheus and Grafana to monitor your Flask application running in Docker. Here's how the monitoring system is set up and how you can use it:

### 1️⃣ Prometheus Configuration

Prometheus is configured to scrape metrics from:

- **Node Exporter**: Provides hardware and OS metrics from the EC2 instance.
- **Flask App**: You can extend Prometheus to scrape Flask app-specific metrics by exposing an endpoint in your Flask application.

Prometheus config (`prometheus.yml`) is located in the `ansible/monitoring` directory and is set up to scrape both `Node Exporter` and `Flask App`.

---

### 2️⃣ Grafana Dashboard

Once the infrastructure is set up and the containers are running, you can access the Grafana dashboard at:

- **Grafana URL**: `http://<EC2-Public-IP>:3000`

#### Default Login:
- **Username**: `admin`
- **Password**: `admin`

Upon logging in, you can import and view pre-configured dashboards to monitor:

- EC2 metrics (CPU, memory, disk usage, etc.)
- Flask application performance (e.g., request rate, response time)

> 🔧 You can also create custom dashboards and panels as per your monitoring needs.

---

### 3️⃣ Node Exporter

Node Exporter runs on the EC2 instance and exposes various system metrics (CPU, memory, disk, network usage). It is available on port `9100`:

- **Node Exporter URL**: `http://<EC2-Public-IP>:9100/metrics`

---

### 4️⃣ Alerts (Optional)

You can configure alerting in Prometheus or Grafana to notify you on various conditions like:

- High CPU usage
- Flask app down
- Low disk space

This requires setting up notification channels like email, Slack, or others, depending on your preference.

### Step 9: 🛠️ Troubleshooting

While working with Flask, Docker, Ansible, and Terraform, issues might arise. Here are some common problems and their solutions:

### 1️⃣ **EC2 Instance Not Starting**

- **Cause**: The EC2 instance might not have started successfully.
- **Solution**: 
  - Check EC2 instance status in the AWS console.
  - Ensure that the `ami_id` in your Terraform configuration is correct.
  - Review the instance's **System Logs** in the AWS console for error messages.

### 2️⃣ **Docker Containers Not Running**

- **Cause**: Docker containers might not be starting as expected.
- **Solution**: 
  - Check the container logs:
    ```bash
    docker logs <container-name>
    ```
  - Ensure Docker service is running:
    ```bash
    systemctl status docker
    ```
  - Inspect the running containers:
    ```bash
    docker ps
    ```
  
### 3️⃣ **Flask App Not Accessible**

- **Cause**: Flask app may not be accessible from the browser.
- **Solution**:
  - Verify if the Flask app container is running and the port is exposed properly (`5000:5000`).
  - Ensure the **Security Group** rules for the EC2 instance are configured correctly to allow access to port `5000`.
  - Check the **Docker logs** for the Flask app container:
    ```bash
    docker logs flask-app-container
    ```

### 4️⃣ **Prometheus/Grafana Not Displaying Data**

- **Cause**: Prometheus and Grafana may not be receiving data.
- **Solution**:
  - Ensure Prometheus is scraping both **Node Exporter** and the **Flask App**.
  - Check the Prometheus logs for any scraping errors.
  - Ensure the correct targets are listed in Prometheus' **`prometheus.yml`** file.
  - In Grafana, ensure the data source is correctly configured to point to the Prometheus instance.

### 5️⃣ **Terraform Apply Fails**

- **Cause**: Terraform might fail to apply changes due to misconfigurations.
- **Solution**:
  - Check the error messages printed by Terraform.
  - Ensure that AWS credentials are correctly configured for Terraform.
  - Run `terraform plan` to inspect the planned changes and validate before applying.
  - For any IAM-related issues, ensure the IAM user has the correct permissions for creating resources.

### 6️⃣ **Ansible Playbook Fails**

- **Cause**: The Ansible playbook might fail due to incorrect configurations or missing dependencies.
- **Solution**:
  - Check the output logs for the error messages.
  - Ensure the EC2 instance is reachable and that SSH keys are correctly configured.
  - Verify that the necessary roles and variables are defined in the `ansible/` directory.
  - Run the playbook with increased verbosity for more detailed logs:
    ```bash
    ansible-playbook -v playbook.yml
    ```
  
### 7️⃣ **Security Group Issues**

- **Cause**: EC2 instances or services might not be accessible due to misconfigured security groups.
- **Solution**:
  - Verify the security group rules in the AWS Console.
  - Ensure that ports like `5000` (Flask app) and `3000` (Grafana) are open to the right CIDR blocks.
  - Check for overlapping security group configurations that may cause conflicts.

### Step 10: 🛠️ To-Do / 🚀 Future Enhancements  

As the project grows, there are several areas where we can improve and add additional features to enhance the scalability, performance, and maintainability of the system.

### 1️⃣ **Automated Testing and CI/CD**

- **Enhancement**: Integrate automated tests for Flask app endpoints and Docker container functionality.
- **Benefit**: Ensure that the Flask app remains reliable as features and functionality evolve.
- **Tools**: 
  - **pytest** for unit testing Flask routes.
  - **GitHub Actions** for setting up continuous integration and deployment pipelines.

### 2️⃣ **Multi-Region Deployment**

- **Enhancement**: Extend the infrastructure setup to support multi-region deployment on AWS.
- **Benefit**: Improve availability and performance by deploying to multiple AWS regions.
- **Steps**:
  - Modify the Terraform configuration to deploy resources across multiple regions.
  - Use AWS Route 53 for traffic routing between regions.

### 3️⃣ **Container Orchestration with Kubernetes**

- **Enhancement**: Migrate the Flask app and monitoring stack to a **Kubernetes** setup.
- **Benefit**: Enable easier scaling, management, and orchestration of Docker containers.
- **Tools**: 
  - **Kubernetes** for container orchestration.
  - **Helm** for managing Kubernetes charts and deployments.
  - **AWS EKS** for a managed Kubernetes service.

### 4️⃣ **Logging and Monitoring Enhancements**

- **Enhancement**: Expand logging capabilities to capture detailed application logs and errors.
- **Benefit**: Improve debugging and performance monitoring.
- **Tools**:
  - **ELK Stack** (Elasticsearch, Logstash, Kibana) for centralized logging.
  - **Prometheus** and **Grafana** for enhanced metrics and monitoring.

### 5️⃣ **Application Auto-Scaling**

- **Enhancement**: Implement auto-scaling for the Flask app EC2 instances based on traffic.
- **Benefit**: Handle traffic spikes more effectively by automatically scaling resources.
- **Tools**:
  - **AWS Auto Scaling** to scale EC2 instances.
  - **AWS CloudWatch** for monitoring resource usage and triggering auto-scaling actions.

### 6️⃣ **Database Integration**

- **Enhancement**: Integrate a database such as **PostgreSQL** or **MySQL** with the Flask application.
- **Benefit**: Provide persistent storage for user data and application state.
- **Steps**:
  - Add a database service to the **Docker Compose** setup.
  - Integrate the Flask app to communicate with the database using an ORM like **SQLAlchemy**.

### 7️⃣ **Security Improvements**

- **Enhancement**: Improve security by implementing **SSL/TLS encryption** and securing API endpoints.
- **Benefit**: Secure sensitive data and communications between clients and the server.
- **Steps**:
  - Implement **SSL certificates** for HTTPS in Flask.
  - Set up API authentication using **JWT** tokens or **OAuth**.
  
### 8️⃣ **Cost Optimization**

- **Enhancement**: Optimize cloud infrastructure to reduce unnecessary costs.
- **Benefit**: Reduce operational costs and improve resource efficiency.
- **Tools**:
  - **AWS Cost Explorer** to monitor and analyze costs.
  - **AWS Trusted Advisor** for cost optimization recommendations.

### 9️⃣ **Container Image Optimization**

- **Enhancement**: Optimize the Docker images for smaller sizes and faster deployment.
- **Benefit**: Reduce the container image size and improve deployment times.
- **Tools**:
  - Use **multi-stage builds** in Docker to reduce the final image size.
  - Minimize the number of layers in Docker images.

### 🙌 Acknowledgements

This project is inspired by real-world DevOps pipelines and built to demonstrate full-stack automation using open-source tools.
