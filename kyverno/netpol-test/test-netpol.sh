#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Define test cases as arrays
declare -A TEST_CASES
TEST_CASES=(
    # DNS Access Tests
    ["1"]="dns_dev:dev:kube-system:53:UDP:allow:Dev namespace DNS access"
    
    # Allow Cases - Ingress Controller
    ["2"]="ingress_dev:ingress-nginx:dev:80:TCP:allow:Ingress-nginx to dev namespace"
    ["3"]="ingress_stage:ingress-nginx:stage:80:TCP:allow:Ingress-nginx to stage namespace"
    ["4"]="ingress_prod:ingress-nginx:prod:80:TCP:allow:Ingress-nginx to prod namespace"
    
    # Allow Cases - Jenkins
    ["5"]="jenkins_dev:jenkins:dev:80:TCP:allow:Jenkins to dev namespace"
    ["6"]="jenkins_stage:jenkins:stage:80:TCP:allow:Jenkins to stage namespace"
    ["7"]="jenkins_prod:jenkins:prod:80:TCP:allow:Jenkins to prod namespace"

    # Deny Cases - Default Namespace Isolation
    ["8"]="default_dev:default:dev:80:TCP:deny:Default namespace to dev communication"
    ["9"]="default_stage:default:stage:80:TCP:deny:Default namespace to stage communication"
    ["10"]="default_prod:default:prod:80:TCP:deny:Default namespace to prod communication"
    
    # Deny Cases - Cross Environment Isolation
    ["11"]="dev_stage:dev:stage:80:TCP:deny:Dev to Stage isolation"
    ["12"]="stage_dev:stage:dev:80:TCP:deny:Stage to Dev isolation"
    ["13"]="dev_prod:dev:prod:80:TCP:deny:Dev to Prod isolation"
    ["14"]="prod_dev:prod:dev:80:TCP:deny:Prod to Dev isolation"
    ["15"]="stage_prod:stage:prod:80:TCP:deny:Stage to Prod isolation"
    ["16"]="prod_stage:prod:stage:80:TCP:deny:Prod to Stage isolation"

    # Deny Cases - Service Isolation
    ["17"]="dev_sonar:dev:sonarqube:9000:TCP:deny:Dev direct access to SonarQube"
    ["18"]="stage_sonar:stage:sonarqube:9000:TCP:deny:Stage direct access to SonarQube"
    ["19"]="prod_sonar:prod:sonarqube:9000:TCP:deny:Prod direct access to SonarQube"
    ["20"]="dev_jenkins:dev:jenkins:8080:TCP:deny:Dev direct access to Jenkins"
    ["21"]="stage_jenkins:stage:jenkins:8080:TCP:deny:Stage direct access to Jenkins"
    ["22"]="prod_jenkins:prod:jenkins:8080:TCP:deny:Prod direct access to Jenkins"

    # Allow Cases - Keycloak Access
    ["23"]="dev_keycloak:dev:keycloak:8080:TCP:allow:Dev to Keycloak access"
    ["24"]="stage_keycloak:stage:keycloak:8080:TCP:allow:Stage to Keycloak access"
    ["25"]="prod_keycloak:prod:keycloak:8080:TCP:allow:Prod to Keycloak access"

    # Allow Cases - AWS Services
    ["26"]="dev_rds:dev:default:5432:TCP:allow:Dev RDS access"
    ["27"]="dev_redis:dev:default:6379:TCP:allow:Dev Redis access"
    ["28"]="dev_msk:dev:default:9092:TCP:allow:Dev MSK access"
)

# Function to show menu
show_menu() {
    echo -e "\n${YELLOW}Available Test Cases:${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
    for key in $(echo "${!TEST_CASES[@]}" | tr ' ' '\n' | sort -n); do
        IFS=':' read -r -a test_parts <<< "${TEST_CASES[$key]}"
        # Add color coding based on expected result (allow/deny)
        if [[ "${test_parts[5]}" == "allow" ]]; then
            echo -e "${YELLOW}$key${NC}. ${GREEN}[ALLOW]${NC} ${test_parts[6]}"
        else
            echo -e "${YELLOW}$key${NC}. ${RED}[DENY]${NC} ${test_parts[6]}"
        fi
    done
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}a${NC}. Run all tests"
    echo -e "${YELLOW}d${NC}. Run all deny tests"
    echo -e "${YELLOW}p${NC}. Run all allow tests"
    echo -e "${YELLOW}q${NC}. Quit"
}
# Function to generate unique pod name
generate_pod_name() {
    local base_name=$1
    echo "${base_name}-$(date +%s)-${RANDOM}"
}

# Function to wait for pod deletion
wait_for_pod_deletion() {
    local pod_name=$1
    local namespace=$2
    local max_attempts=30
    local attempt=1

    while kubectl get pod ${pod_name} -n ${namespace} >/dev/null 2>&1; do
        if [ $attempt -ge $max_attempts ]; then
            echo -e "${RED}Timeout waiting for pod ${pod_name} deletion${NC}"
            return 1
        fi
        echo -e "Waiting for pod ${pod_name} deletion... attempt ${attempt}/${max_attempts}"
        sleep 2
        ((attempt++))
    done
}
# Function to test connection
test_connection() {
    local from_ns=$1
    local to_ns=$2
    local port=$3
    local protocol=${4:-TCP}
    local expected=$5
    local description=$6

    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}TEST CASE: ${description}${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"

    # Verify namespaces exist
    if ! kubectl get namespace "$from_ns" >/dev/null 2>&1; then
        echo -e "${RED}Error: Source namespace '$from_ns' does not exist. Skipping test.${NC}"
        return 1
    fi

    if ! kubectl get namespace "$to_ns" >/dev/null 2>&1; then
        echo -e "${RED}Error: Destination namespace '$to_ns' does not exist. Skipping test.${NC}"
        return 1
    fi

    echo -e "\n${YELLOW}Test Details:${NC}"
    echo -e "• From Namespace: ${BLUE}$from_ns${NC}"
    echo -e "• To Namespace:   ${BLUE}$to_ns${NC}"
    echo -e "• Port:          ${BLUE}$port${NC}"
    echo -e "• Protocol:      ${BLUE}$protocol${NC}"
    echo -e "• Expected:      ${BLUE}$expected${NC}"

    # Generate unique pod names
    local source_pod=$(generate_pod_name "netpol-test-source")
    local dest_pod=$(generate_pod_name "netpol-test-dest")

    echo -e "\n${YELLOW}1. Creating test pods...${NC}"
    
    # Create source pod
    echo -e "• Creating source pod ${source_pod} in namespace ${from_ns}"
    kubectl run ${source_pod} --image=nicolaka/netshoot -n "$from_ns" --labels="app=netpol-test-source" -- sleep 3600 >/dev/null 2>&1
    
    # Create destination pod
    echo -e "• Creating destination pod ${dest_pod} in namespace ${to_ns}"
    if [ "$protocol" = "TCP" ]; then
        kubectl run ${dest_pod} --image=nicolaka/netshoot -n "$to_ns" --labels="app=netpol-test-dest" -- /bin/sh -c "while true; do nc -lvk -p ${port} >/dev/null 2>&1; done" >/dev/null 2>&1
    else
        kubectl run ${dest_pod} --image=nicolaka/netshoot -n "$to_ns" --labels="app=netpol-test-dest" -- /bin/sh -c "while true; do nc -luk -p ${port} >/dev/null 2>&1; done" >/dev/null 2>&1
    fi

    echo -e "\n${YELLOW}2. Waiting for pods to be ready...${NC}"
    
    echo -e "• Waiting for source pod..."
    if ! kubectl wait --for=condition=Ready pod/${source_pod} -n "$from_ns" --timeout=30s >/dev/null 2>&1; then
        echo -e "${RED}Error: Source pod failed to become ready${NC}"
        # Cleanup on failure
        kubectl delete pod ${source_pod} -n "$from_ns" --wait=true >/dev/null 2>&1
        kubectl delete pod ${dest_pod} -n "$to_ns" --wait=true >/dev/null 2>&1
        return 1
    fi
    echo -e "• Source pod ready"

    echo -e "• Waiting for destination pod..."
    if ! kubectl wait --for=condition=Ready pod/${dest_pod} -n "$to_ns" --timeout=30s >/dev/null 2>&1; then
        echo -e "${RED}Error: Destination pod failed to become ready${NC}"
        # Cleanup on failure
        kubectl delete pod ${source_pod} -n "$from_ns" --wait=true >/dev/null 2>&1
        kubectl delete pod ${dest_pod} -n "$to_ns" --wait=true >/dev/null 2>&1
        return 1
    fi
    echo -e "• Destination pod ready"

    # Get the IP address of the destination pod
    dest_ip=$(kubectl get pod ${dest_pod} -n "$to_ns" -o jsonpath='{.status.podIP}')
    echo -e "• Destination pod IP: ${BLUE}$dest_ip${NC}"

    echo -e "\n${YELLOW}3. Testing connection...${NC}"
    if [ "$protocol" = "TCP" ]; then
        result=$(kubectl exec -n "$from_ns" ${source_pod} -- nc -zv -w 5 $dest_ip "$port" 2>&1 || echo "failed")
    else
        result=$(kubectl exec -n "$from_ns" ${source_pod} -- nc -zuv -w 5 $dest_ip "$port" 2>&1 || echo "failed")
    fi

    echo -e "\n${YELLOW}4. Cleaning up test pods...${NC}"
    echo -e "• Deleting source pod ${source_pod}"
    kubectl delete pod ${source_pod} -n "$from_ns" --wait=true
    wait_for_pod_deletion ${source_pod} ${from_ns}
    
    echo -e "• Deleting destination pod ${dest_pod}"
    kubectl delete pod ${dest_pod} -n "$to_ns" --wait=true
    wait_for_pod_deletion ${dest_pod} ${to_ns}
    
    echo -e "• Cleanup completed"

    echo -e "\n${YELLOW}5. Test Result:${NC}"
    if [[ "$expected" == "allow" && "$result" != *"failed"* ]]; then
        echo -e "${GREEN}✓ SUCCESS: Connection allowed as expected${NC}"
        echo -e "• Result details: $result"
    elif [[ "$expected" == "deny" && "$result" == *"failed"* ]]; then
        echo -e "${GREEN}✓ SUCCESS: Connection blocked as expected${NC}"
        echo -e "• Result details: Connection timeout/refused (expected behavior)"
    else
        echo -e "${RED}✗ FAILED: Unexpected result${NC}"
        echo -e "• Expected: $expected"
        echo -e "• Got: $result"
    fi
}

# Main execution
echo -e "${YELLOW}╔════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║                   Network Policy Compliance Testing                     ║${NC}"
echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════════════╝${NC}"

# Main loop
while true; do
    show_menu
    echo -e "\n${YELLOW}Enter your choice (number, 'a' for all, 'd' for deny tests, 'p' for allow tests, or 'q' to quit):${NC} "
    read -r choice

    if [[ $choice == "q" ]]; then
        echo -e "${YELLOW}Exiting...${NC}"
        break
    elif [[ $choice == "a" ]]; then
        echo -e "${YELLOW}Running all tests...${NC}"
        for key in $(echo "${!TEST_CASES[@]}" | tr ' ' '\n' | sort -n); do
            IFS=':' read -r id from_ns to_ns port protocol expected description <<< "${TEST_CASES[$key]}"
            test_connection "$from_ns" "$to_ns" "$port" "$protocol" "$expected" "$description"
        done
    elif [[ $choice == "d" ]]; then
        echo -e "${YELLOW}Running all deny tests...${NC}"
        for key in $(echo "${!TEST_CASES[@]}" | tr ' ' '\n' | sort -n); do
            IFS=':' read -r id from_ns to_ns port protocol expected description <<< "${TEST_CASES[$key]}"
            if [[ "$expected" == "deny" ]]; then
                test_connection "$from_ns" "$to_ns" "$port" "$protocol" "$expected" "$description"
            fi
        done
    elif [[ $choice == "p" ]]; then
        echo -e "${YELLOW}Running all allow tests...${NC}"
        for key in $(echo "${!TEST_CASES[@]}" | tr ' ' '\n' | sort -n); do
            IFS=':' read -r id from_ns to_ns port protocol expected description <<< "${TEST_CASES[$key]}"
            if [[ "$expected" == "allow" ]]; then
                test_connection "$from_ns" "$to_ns" "$port" "$protocol" "$expected" "$description"
            fi
        done
    elif [[ -n "${TEST_CASES[$choice]}" ]]; then
        IFS=':' read -r id from_ns to_ns port protocol expected description <<< "${TEST_CASES[$choice]}"
        test_connection "$from_ns" "$to_ns" "$port" "$protocol" "$expected" "$description"
    else
        echo -e "${RED}Invalid choice. Please try again.${NC}"
    fi

    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read -r
    clear
done