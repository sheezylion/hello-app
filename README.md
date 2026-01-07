# Hello Net

A basic Go program that responds to requests with an environment variable templated into the response.

# Building and Running

## Locally

1. [Install Go](https://golang.org/doc/install)

1. Build and/or run

   ```
   go build main.go
   ./main
   ```

   or

   ```
   go run main.go
   ```

## With Docker

   ```
   docker build -t hello-world .
   docker run -e "ENV=production" --rm -p 8080:8080 hello-world
   ```

# Interacting

Visit `localhost:8080/hello` to see the response.

For example:
```
Hello! I am running in production
```


# Hello Service — Automated Infrastructure & Deployment

This project demonstrates a fully automated deployment pipeline for a simple Go web service, 
covering infrastructure provisioning, configuration management, containerization, reverse proxying, and TLS security.

The goal was not just to “make it work”, but to implement a repeatable, production-style workflow using Infrastructure as Code and Configuration Management best practices.

## Architecture Overview

### **Terraform**

- Provisions AWS infrastructure (EC2, Security Group, Elastic IP)

- Ensures a stable public IP for DNS mapping


### **Ansible**

- Configures the server

- Installs required system packages

- Builds and runs the application in Docker

- Configures NGINX as a reverse proxy

- Secures traffic using Let’s Encrypt (Certbot)

### **Docker**

Runs two isolated environments from the same image:

- Production

- Staging

### **NGINX**

- Routes traffic by subdomain

- Terminates TLS (HTTPS)

### **Domain & Environment Setup**

Base domain:
- asgnmnt.space

Subdomains:

- production.asgnmnt.space → Production environment

- staging.asgnmnt.space → Staging environment

Each subdomain points to the same Elastic IP, and NGINX routes traffic internally to the correct container.

<img width="1299" height="804" alt="Screenshot 2026-01-07 at 03 20 49" src="https://github.com/user-attachments/assets/04da9704-edae-4235-8121-5d5c431f2925" />

## Infrastructure Provisioning (Terraform)

Terraform is responsible for infrastructure only.

What Terraform provisions:

- EC2 instance

- Security Group (ports 22, 80, 443)

- Elastic IP (static public IP)

Why Elastic IP?

- EC2 public IPs change on stop/start.

- Using an Elastic IP ensures DNS records remain valid even if the instance lifecycle changes.

Terraform workflow:

```
terraform init
terraform plan
terraform apply
```

After provisioning, the Elastic IP is added to Namecheap DNS records as A records for both subdomains.

## Configuration & Deployment (Ansible)

Ansible handles everything inside the server.

**Role-based structure:**

```
ansible/
├── roles/
│   ├── common    # system updates & base packages
│   ├── docker    # docker installation & setup
│   ├── app       # clone repo, build image, run containers
│   ├── nginx     # reverse proxy configuration
│   └── certbot   # TLS certificates via Let's Encrypt

```


This ensures:

- The app is running on HTTP

- Domains resolve correctly

- Certbot can validate and issue certificates successfully

## Application Runtime (Docker)

- A single Docker image is built from the repository

- Two containers are created from the same image:

   - hello-prod → port 8080

   - hello-staging → port 8081

Ansible uses the docker_container module to ensure:

- Idempotency

- Safe re-runs

- Automatic restarts


## Traffic Routing (NGINX)

NGINX acts as a reverse proxy:
- production.asgnmnt.space	127.0.0.1:8080

- staging.asgnmnt.space	127.0.0.1:8081

The NGINX configuration is deployed via Ansible templates, allowing easy updates and reuse.

## HTTPS & TLS (using Lets Encrypt)

TLS certificates are issued automatically using Certbot with the NGINX plugin.

Key points:

- Certificates are requested only after HTTP is live

- Certbot modifies NGINX config safely

- Certificates are reused and not reissued unnecessarily

- HTTPS is enforced via redirect

- This avoids common Certbot failures caused by premature SSL configuration.

## **Architecture & Design Decisions**

Why Terraform?

- Declarative infrastructure

- Easy teardown (terraform destroy)

- Cloud-agnostic principles

- Prevents manual AWS drift

Why Ansible?

- Agentless

- Human-readable

- Excellent for server configuration

- Idempotent by design

Why separate Terraform & Ansible?

- Each tool does one job well:

- Terraform → infrastructure lifecycle

- Ansible → system & application configuration

This separation mirrors real-world production practices.


## **How to Run the Full Automation**

Provision infrastructure

```
cd terraform
terraform apply
```
<img width="832" height="566" alt="Screenshot 2026-01-07 at 01 12 09" src="https://github.com/user-attachments/assets/82e7e62b-3945-4ad7-81dd-bfccea456643" />

Update DNS

- Point production.asgnmnt.space and staging.asgnmnt.space To the Elastic IP created by Terraform

<img width="1299" height="804" alt="Screenshot 2026-01-07 at 03 20 49" src="https://github.com/user-attachments/assets/f358bf54-bf01-4543-a469-a9334e4d7435" />


Configure & deploy

```
cd ansible
ansible-playbook -i inventory.ini site.yml
```
<img width="1011" height="579" alt="Screenshot 2026-01-07 at 02 02 47" src="https://github.com/user-attachments/assets/d3bd57a1-e4d2-4511-b747-10b7f22ae10d" />

<img width="1446" height="511" alt="Screenshot 2026-01-07 at 03 14 09" src="https://github.com/user-attachments/assets/db1301e3-48d8-4f0c-87da-c88caf182a3f" />

<img width="1173" height="532" alt="Screenshot 2026-01-07 at 03 14 29" src="https://github.com/user-attachments/assets/5ca0ff6b-efe8-44ef-97f9-ff7f0919721a" />

<img width="1037" height="788" alt="Screenshot 2026-01-07 at 03 14 45" src="https://github.com/user-attachments/assets/010f3bc1-cdfc-4627-a8ef-3440b819b767" />

### Conclusion
This project focuses on automation. Every decision was made to reflect real-world DevOps workflows and best practices.

- Fully automated infrastructure

- Zero manual server configuration

- Secure HTTPS endpoints

- Production and staging environments

- Repeatable and destroyable setup



