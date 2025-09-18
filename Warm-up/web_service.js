#!/usr/bin/env node

const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const crypto = require('crypto');
const app = express();

// Middleware
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// Database connection
const db = new sqlite3.Database('/opt/challenge/web_vuln/challenge.db');

// Simple logging
function log(message) {
    console.log(`[${new Date().toISOString()}] ${message}`);
}

// Home page
app.get('/', (req, res) => {
    res.send(`
    <html>
    <head><title>Quantum Secure Login Portal</title></head>
    <body style="font-family: monospace; background: #1a1a1a; color: #00ff00; padding: 20px;">
        <h1>🔐 QUANTUM SECURE AUTHENTICATION SYSTEM 🔐</h1>
        <p>Access Level: CLASSIFIED</p>
        <p>Security Protocol: MAXIMUM</p>
        
        <h2>Authentication Required</h2>
        <form method="POST" action="/login">
            <label>Username:</label><br>
            <input type="text" name="username" style="padding: 5px; margin: 5px;"><br>
            <label>Password:</label><br>
            <input type="password" name="password" style="padding: 5px; margin: 5px;"><br>
            <input type="submit" value="ACCESS SYSTEM" style="padding: 10px; margin: 10px; background: #003300; color: #00ff00; border: 1px solid #00ff00;">
        </form>
        
        <hr>
        <h3>📊 System Statistics</h3>
        <a href="/stats" style="color: #00ff00;">View Database Statistics</a> (Public Access)
        <br><br>
        <h3>🔍 Search Function</h3>
        <form method="GET" action="/search">
            <input type="text" name="query" placeholder="Search users..." style="padding: 5px;">
            <input type="submit" value="SEARCH" style="padding: 5px; background: #003300; color: #00ff00; border: 1px solid #00ff00;">
        </form>
        
        <div style="margin-top: 30px; font-size: 0.8em; color: #666;">
            <p>💡 Hint: SQL injection vulnerabilities might exist in search functionality...</p>
            <p>🎯 Target: Admin panel contains encrypted secrets</p>
        </div>
    </body>
    </html>
    `);
});

// Vulnerable search function (SQL Injection point)
app.get('/search', (req, res) => {
    const query = req.query.query;
    
    if (!query) {
        return res.send('Please provide a search query.');
    }
    
    log(`Search query: ${query}`);
    
    // VULNERABLE: Direct string concatenation (SQL injection)
    const sql = `SELECT username, role FROM users WHERE username LIKE '%${query}%' OR role LIKE '%${query}%'`;
    
    db.all(sql, (err, rows) => {
        if (err) {
            log(`Database error: ${err.message}`);
            return res.send(`
                <div style="color: red; font-family: monospace;">
                    Database Error: ${err.message}<br>
                    <a href="/">Back to Home</a>
                </div>
            `);
        }
        
        let results = '<html><body style="font-family: monospace; background: #1a1a1a; color: #00ff00; padding: 20px;">';
        results += `<h2>Search Results for: "${query}"</h2>`;
        
        if (rows.length === 0) {
            results += '<p>No results found.</p>';
        } else {
            results += '<table border="1" style="color: #00ff00; border-color: #00ff00;">';
            results += '<tr><th>Username</th><th>Role</th></tr>';
            rows.forEach(row => {
                results += `<tr><td>${row.username}</td><td>${row.role}</td></tr>`;
            });
            results += '</table>';
        }
        
        results += '<br><a href="/" style="color: #00ff00;">Back to Home</a></body></html>';
        res.send(results);
    });
});

// Stats page (reveals database structure)
app.get('/stats', (req, res) => {
    db.all("SELECT name FROM sqlite_master WHERE type='table'", (err, tables) => {
        if (err) {
            return res.send('Error retrieving stats');
        }
        
        let stats = '<html><body style="font-family: monospace; background: #1a1a1a; color: #00ff00; padding: 20px;">';
        stats += '<h2>📊 Database Statistics</h2>';
        stats += '<h3>Available Tables:</h3>';
        
        tables.forEach(table => {
            stats += `<p>🗃️ Table: <strong>${table.name}</strong></p>`;
        });
        
        // Show table structures (this is a hint for attackers)
        db.all("PRAGMA table_info(secret_keys)", (err, columns) => {
            if (!err && columns.length > 0) {
                stats += '<h4>Secret Keys Table Structure:</h4>';
                stats += '<ul>';
                columns.forEach(col => {
                    stats += `<li>${col.name} (${col.type})</li>`;
                });
                stats += '</ul>';
                
                stats += '<p style="color: #ffff00;">💡 Hint: Advanced queries can extract data from any table...</p>';
            }
            
            stats += '<br><a href="/" style="color: #00ff00;">Back to Home</a></body></html>';
            res.send(stats);
        });
    });
});

// Login endpoint
app.post('/login', (req, res) => {
    const { username, password } = req.body;
    
    log(`Login attempt: ${username}`);
    
    // Hash the password (SHA-256)
    const hashedPassword = crypto.createHash('sha256').update(password).digest('hex');
    
    db.get("SELECT * FROM users WHERE username = ? AND password = ?", [username, hashedPassword], (err, row) => {
        if (err) {
            return res.send('Database error during login');
        }
        
        if (row) {
            if (row.role === 'administrator') {
                res.send(`
                <html><body style="font-family: monospace; background: #1a1a1a; color: #00ff00; padding: 20px;">
                    <h1>🎉 ADMIN ACCESS GRANTED! 🎉</h1>
                    <p>Welcome, Administrator ${row.username}!</p>
                    <h2>🔑 Secret Database Access</h2>
                    <p>You now have access to the encrypted secrets.</p>
                    <p>💎 Admin privilege allows you to view the secret_keys table.</p>
                    
                    <h3>Next Steps:</h3>
                    <ul>
                        <li>✅ SQL injection successful</li>
                        <li>🎯 Look for base64 encoded data in secret_keys table</li>
                        <li>🚀 Decode the vault_access and next_stage entries</li>
                        <li>⚡ Use the decoded information for privilege escalation</li>
                    </ul>
                    
                    <p style="color: #ffff00;">
                        Hint: Try SQL injection to extract encrypted_data from secret_keys:<br>
                        <code>' UNION SELECT encrypted_data, key_name FROM secret_keys --</code>
                    </p>
                </body></html>
                `);
            } else {
                res.send('Access granted, but insufficient privileges for admin panel.');
            }
        } else {
            res.send(`
            <html><body style="font-family: monospace; background: #1a1a1a; color: #ff0000; padding: 20px;">
                <h2>❌ ACCESS DENIED</h2>
                <p>Invalid credentials.</p>
                <p>💡 Hint: Admin password hash is stored in the database...</p>
                <a href="/" style="color: #00ff00;">Try Again</a>
            </body></html>
            `);
        }
    });
});

// Error handling
app.use((err, req, res, next) => {
    log(`Error: ${err.message}`);
    res.status(500).send('Internal server error');
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
    log(`Quantum Secure Portal running on port ${PORT}`);
    log('SQL injection vulnerabilities active for testing purposes');
});

// Graceful shutdown
process.on('SIGTERM', () => {
    db.close();
    process.exit(0);
});
