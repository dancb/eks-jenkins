#!/bin/bash
/etc/eks/bootstrap.sh ${cluster_name} --kubelet-extra-args '--node-labels eks.amazonaws.com/nodegroup=${cluster_name}'
