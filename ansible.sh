#!/bin/bash

terraform-inventory.sh --inventory > /inv 
ansible-playbook -i /inv $@