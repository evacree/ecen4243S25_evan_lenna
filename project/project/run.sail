#!/bin/sh
riscv_sim_rv32d --pmp-count=16 project | tee log

