#!/bin/bash

ansible-playbook /home/slava/ansible1/playbooks/createVM.yml
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i /home/slava/ansible/contrib/inventory/azure_rm.py /home/slava/ansible1/playbooks/env.yml --extra-vars "hosts=sultVM" -vvvv

