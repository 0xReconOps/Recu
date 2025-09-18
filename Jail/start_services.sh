#!/bin/bash

echo "🐍 Starting Python Jail PWN Challenge services..."

# Start SSH daemon
echo "🔧 Starting SSH daemon..."
/usr/sbin/sshd -D &
SSH_PID=$!

# Wait for SSH to initialize
sleep 3

# Start the Python jail service
echo "🐍 Starting Python Jail on port 9999..."
/opt/pyjail/start_jail.sh &
JAIL_PID=$!

echo "✅ Services started successfully!"
echo "   - SSH: Port 22 (user: pwnuser, pass: jail2024)"
echo "   - Python Jail: Port 9999 (nc localhost 9999)"
echo "   - Challenge ready!"

# Function to handle shutdown
shutdown() {
    echo "🛑 Shutting down services..."
    kill $SSH_PID $JAIL_PID 2>/dev/null
    exit 0
}

# Set up signal handlers
trap shutdown SIGTERM SIGINT

# Keep container running and monitor services
while true; do
    # Check if SSH is still running
    if ! kill -0 $SSH_PID 2>/dev/null; then
        echo "⚠️  SSH daemon died, restarting..."
        /usr/sbin/sshd -D &
        SSH_PID=$!
    fi
    
    # Check if jail service is still running
    if ! kill -0 $JAIL_PID 2>/dev/null; then
        echo "⚠️  Jail service died, restarting..."
        /opt/pyjail/start_jail.sh &
        JAIL_PID=$!
    fi
    
    sleep 10
done
