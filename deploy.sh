#!/bin/bash

set -e

echo "╔═══════════════════════════════════════════════════════╗"
echo "║     K3S LITE Cluster Deployment Automation            ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}[1/5] Checking prerequisites...${NC}"
    
    # Check if running on Debian
    if [ ! -f /etc/debian_version ]; then
        echo -e "${RED}Error: This script must run on Debian${NC}"
        exit 1
    fi
    
    # Check for SSH key
    if [ ! -f ~/.ssh/id_ed25519.pub ]; then
        echo -e "${RED}Error: SSH public key not found at ~/.ssh/id_ed25519.pub${NC}"
        exit 1
    fi
    
    # Check for required tools
    for cmd in terraform ansible-playbook ssh; do
        if ! command -v $cmd &> /dev/null; then
            echo -e "${RED}Error: $cmd is not installed${NC}"
            exit 1
        fi
    done
    
    echo -e "${GREEN}✓ Prerequisites check passed${NC}"
    echo ""
}

# Setup Terraform
setup_terraform() {
    echo -e "${YELLOW}[2/5] Setting up Terraform...${NC}"
        
    if [ ! -f terraform.tfvars ]; then
        echo -e "${RED}Error: terraform.tfvars not found${NC}"
        echo "Please copy terraform.tfvars.example to terraform.tfvars and configure it"
        exit 1
    fi
    
    terraform init
    echo -e "${GREEN}✓ Terraform initialized${NC}"
    echo ""
}

# Deploy infrastructure
deploy_infrastructure() {
    echo -e "${YELLOW}[3/5] Deploying infrastructure with Terraform...${NC}"
        
    terraform plan
    echo ""
#    read -p "Do you want to apply this plan? (yes/no): " confirm
    
#    if [ "$confirm" == "yes" ]; then
    terraform apply -auto-approve
#    rm tfplan
    echo -e "${GREEN}✓ Infrastructure deployed${NC}"
#    else
#        echo -e "${RED}Deployment cancelled${NC}"
#        exit 1
#    fi
    
    echo ""
}

# Wait for VMs
wait_for_vms() {
    echo -e "${YELLOW}[4/5] Waiting for VMs to be ready...${NC}"
    sleep 30
    echo -e "${GREEN}✓ VMs are ready${NC}"
    echo ""
}

# Deploy K3S cluster
deploy_k3s() {
    echo -e "${YELLOW}[5/5] Deploying K3S LITE cluster with Ansible...${NC}"
        
    # Verify inventory exists
    if [ ! -f inventory.yml ]; then
        echo -e "${RED}Error: inventory.yml not found${NC}"
        exit 1
    fi
    
    # Test connectivity
    echo "Testing connectivity to all VMs..."
    ansible all -i inventory.yml -m ping
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Cannot connect to some VMs${NC}"
        exit 1
    fi
    
    # Deploy cluster
    ansible-playbook -i inventory.yml site.yml
    
    echo -e "${GREEN}✓ K3S cluster deployed${NC}"
    echo ""
}

# Display summary
display_summary() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║           Deployment Complete!                        ║"
    echo "╠═══════════════════════════════════════════════════════╣"
    echo "║                                                       ║"
    echo "║ Kubeconfig: ~/.kube/config                            ║"
    echo "║                                                       ║"
    echo "║ Test your cluster:                                    ║"
    echo "║   kubectl get nodes                                   ║"
    echo "║   kubectl get pods -A                                 ║"
    echo "║                                                       ║"
    echo "║                                                       ║"
    echo "║                                                       ║"
    echo "║                                                       ║"
    echo "║                                                       ║"
    echo "║                                                       ║"
    echo "╚═══════════════════════════════════════════════════════╝"
}

# Main execution
main() {
    check_prerequisites
    setup_terraform
    deploy_infrastructure
    wait_for_vms
    deploy_k3s
    display_summary
}

# Run main function
main
