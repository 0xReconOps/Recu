#!/bin/bash

# Start SSH daemon
/usr/sbin/sshd -D &

# Wait a moment for SSH to initialize
sleep 2

# Start the vulnerable web service
echo "Starting Quantum Secure Portal on port 3000..."
cd /opt/challenge
node web_service.js &

# Keep container running
wait
