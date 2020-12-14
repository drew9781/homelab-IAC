#!/bin/bash

terraform show --json > /terraform.tfstate
terraform-inventory $@