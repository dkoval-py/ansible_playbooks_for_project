#!/bin/bash
# Script for parsing Public IP and Instance ID from json file that's generated by ansible create ec2 aws instance role

# Define seperator and read json file
IFS=',' read -r -a array <<< `cat /home/Ansible_playbooks/result.txt`

# Read each element from file
for element in "${array[@]}"
do
    # Check condition
    if [[ $element == *public_ip* ]]; then
        # Parse result
        ip_address=`echo $element | awk -F': ' '{print $2}'| sed 's/$*"//' | sed 's/"*$//'`
        # Find string for replacing
        replace_str1=`grep -o "ansible_host.*" /home/Ansible_playbooks/hosts.txt `
        # Replace string in inventory file
        replace ${replace_str1} "ansible_host=${ip_address}" -- /home/Ansible_playbooks/hosts.txt > /dev/null 2>&1
    fi
    if [[ $element == *instance_ids* ]]; then
        # Parse result
        instance_ids=`echo $element | awk -F': ' '{print $2}'| sed 's/$*"]//' | sed 's/\["$*//'`
        echo $instance_ids
        # Find string for replacing
        replace_str2=`grep -o "instance_ids:.*" /home/Ansible_playbooks/roles/delete_ec2/tasks/main.yml`
        echo $replace_str2
        # Replace string in role
        replace "${replace_str2}" "instance_ids: ${instance_ids}" -- /home/Ansible_playbooks/roles/delete_ec2/tasks/main.yml > /dev/null 2>&1
    fi
done