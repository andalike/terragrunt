#!/bin/bash

# Initialize an empty array to store unique environment names
environments=()

# Read input paths from "abc.txt" line by line
while IFS= read -r path; do
  # Extract the environment part of the path
  environment=$(echo "$path" | cut -d'/' -f3)
  
  # Check if the environment is already in the array
  if [[ ! " ${environments[@]} " =~ " ${environment} " ]]; then
    # Add the environment to the array
    environments+=("$environment")
  fi
done < "abc.txt"  # Read from the "abc.txt" file

# Count the unique environments
num_environments=${#environments[@]}

# Check if more than two environments are changed
if [ "$num_environments" -gt 2 ]; then
  echo "Error: More than two environments are changed"
else
  # Print the common part of the paths
  common_part=$(echo "$path" | cut -d'/' -f1-4)
  echo "$common_part"
fi
