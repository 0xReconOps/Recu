#!/bin/bash

# Start the Python jail on port 9999
echo "Starting Python Jail on port 9999..."
socat TCP-LISTEN:9999,reuseaddr,fork EXEC:"python3 /opt/pyjail/jail.py",pty,stderr
