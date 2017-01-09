#!/bin/bash


set -x 
curl -vv -H "Content-Type: application/json" -d @vbng.json http://vgp-compute-19:1870/setupvbng


