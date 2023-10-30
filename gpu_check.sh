# Get the list of nodes and their GPU information
node_gpu_info=$(sinfo --Node --format="%N %G")

# Function to check GPU availability for a node
check_gpu_availability() {
    node_name=$1
    available_gpus=$(scontrol show node $node_name | grep Gres | awk '{print $2}')
    echo "$available_gpus"
}

# Function to get the users and their memory allocation using GPUs on a node
get_gpu_users_and_memory() {
    node_name=$1
    gpu_users_with_memory=$(squeue -h -w $node_name -o "%u (%m)" -t "CONFIGURING,RUNNING" | sort -u)
    echo "$gpu_users_with_memory"
}

# Print the header line with column names
echo "NODELIST   GRES       MEMORY      AVAILABILITY   GPU USERS"

# Initialize an array to store users for each node
declare -A users_array

# Iterate through each line of node_gpu_info
while read -r line; do
    node_name=$(echo "$line" | awk '{print $1}')
    gpu_info=$(echo "$line" | awk '{print $2}')
    memory_info=$(scontrol show node $node_name | grep Gres | grep memory | awk '{print $2}')

    available_gpus=$(check_gpu_availability $node_name)
    gpu_users_with_memory=$(get_gpu_users_and_memory $node_name)

    # Check if there are available GPUs for the node
    if [ -z "$available_gpus" ]; then
        availability="Not Available"
        available_gpus="N/A"
    else
        availability="Available"
    fi

    # Store users in the users_array for each node
    users_array[$node_name]="$gpu_users_with_memory"

    # Print the combined information for each node without users
    echo -n "$node_name      $gpu_info      $memory_info      $availability"

    # Print users side-by-side with the "Person-" prefix
    if [ -n "$gpu_users_with_memory" ]; then
        users_list=$(echo "$gpu_users_with_memory" | sed 's/^\(.*\)/\1/' | tr '\n' ' ')
        echo -n "      $users_list"
    fi

    echo
done <<< "$node_gpu_info"
