#!/bin/sh

agent=go-agent2 
target_dir=/var/go/sgx_bin_gen3

echo BEFORE:
docker exec -i $agent ls -l $target_dir

echo REMOVING DIR
docker exec -i $agent rm -r $target_dir 

echo DIR REMOVED
docker exec -i $agent ls -l $target_dir

echo 'CREATING DIR and COPYING R-Car_Gen3_Series_Evaluation_Software_Package_*'
docker exec -i $agent mkdir $target_dir 
tar cf - R-Car_Gen3_Series_Evaluation_Software_Package_* | docker exec -i $agent tar xvf - -C $target_dir/ 

echo AFTER:
docker exec -i $agent ls -l $target_dir
