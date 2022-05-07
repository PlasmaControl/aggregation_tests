#!/bin/bash

for i in {3001..4000}
do
    ./database_maker.wls $i
    echo "$i"
done
