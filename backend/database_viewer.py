#!/usr/bin/env python3
"""
Database Viewer - Web-based database administration tool
Provides a simple web interface to view and manage the database
"""

import os
import sys
import sqlite3
from flask import Flask, render_template_string, request, jsonify, redirect, url_for
import json
from datetime import datetime

# Add the backend directory to the path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

def create_viewer_app():
    """Create Flask app for database viewing"""
    
    app = Flask(__name__)
    app.secret_key = 'database-viewer-secret-key'
    
    # Database path
    DB_PATH = os.path.join(os.path.dirname(__file__), 'app.db')
    
    def get_db_connection():
        """Get database connection"""
        conn = sqlite3.connect(DB_PATH)
        conn.row_factory = sqlite3.Row
        return conn
    
    def get_table_info():
        """Get all table names and their row counts"""
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Get all tables
        cursor.execute("""
            SELECT name FROM sqlite_master 
            WHERE type='table' AND name NOT LIKE 'sqlite_%'
            ORDER BY name
        """)
        tables = cursor.fetchall()
        
        table_info = []
        for table in tables:
            table_name = table['name']
            cursor.execute(f"SELECT COUNT(*) as count FROM {table_name}")
            count = cursor.fetchone()['count']
            
            # Get table schema
            cursor.execute(f"PRAGMA table_info({table_name})")
            columns = cursor.fetchall()
            
            table_info.append({
                'name': table_name,
                'count': count,
                'columns': [col['name'] for col in columns]
            })
        
        conn.close()
        return table_info
    
    @app.route('/')
    def index():
        """Main dashboard"""
        table_info = get_table_info()
        
        html_template = """
        <!DOCTYPE html>
        <html lang="tr">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>ustam - Database Viewer</title>
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f5f5f5; }
                .header { background: #2563eb; color: white; padding: 1rem; text-align: center; }
                .container { max-width: 1200px; margin: 2rem auto; padding: 0 1rem; }
                .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1rem; margin-bottom: 2rem; }
                .stat-card { background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
                .stat-number { font-size: 2rem; font-weight: bold; color: #2563eb; }
                .stat-label { color: #666; margin-top: 0.5rem; }
                .tables-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 1rem; }
                .table-card { background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); overflow: hidden; }
                .table-header { background: #1f2937; color: white; padding: 1rem; display: flex; justify-content: between; align-items: center; }
                .table-name { font-weight: bold; font-size: 1.1rem; }
                .table-count { background: #3b82f6; padding: 0.25rem 0.75rem; border-radius: 12px; font-size: 0.875rem; }
                .table-body { padding: 1rem; }
                .columns { font-size: 0.875rem; color: #666; }
                .column { display: inline-block; background: #f3f4f6; padding: 0.25rem 0.5rem; margin: 0.125rem; border-radius: 4px; }
                .btn { display: inline-block; padding: 0.5rem 1rem; background: #3b82f6; color: white; text-decoration: none; border-radius: 4px; margin-top: 1rem; }
                .btn:hover { background: #2563eb; }
                .refresh-btn { position: fixed; bottom: 2rem; right: 2rem; background: #10b981; color: white; border: none; padding: 1rem; border-radius: 50%; cursor: pointer; box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
                .tools { background: white; padding: 1rem; border-radius: 8px; margin-bottom: 2rem; }
                .tool-btn { display: inline-block; padding: 0.5rem 1rem; margin: 0.25rem; background: #6b7280; color: white; text-decoration: none; border-radius: 4px; }
                .tool-btn:hover { background: #4b5563; }
            </style>
        </head>
        <body>
            <div class="header">
                <h1>🔨 ustam - Database Viewer</h1>
                <p>Production Database Administration Tool</p>
            </div>
            
            <div class="container">
                <div class="stats">
                    <div class="stat-card">
                        <div class="stat-number">{{ table_info|length }}</div>
                        <div class="stat-label">Total Tables</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">{{ total_records }}</div>
                        <div class="stat-label">Total Records</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">{{ db_size }}</div>
                        <div class="stat-label">Database Size</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">{{ current_time }}</div>
                        <div class="stat-label">Last Updated</div>
                    </div>
                </div>
                
                <div class="tools">
                    <h3>🛠️ Database Tools</h3>
                    <a href="/sql" class="tool-btn">SQL Query</a>
                    <a href="/export" class="tool-btn">Export Data</a>
                    <a href="/backup" class="tool-btn">Create Backup</a>
                    <a href="/logs" class="tool-btn">View Logs</a>
                </div>
                
                <div class="tables-grid">
                    {% for table in table_info %}
                    <div class="table-card">
                        <div class="table-header">
                            <div class="table-name">{{ table.name }}</div>
                            <div class="table-count">{{ table.count }} rows</div>
                        </div>
                        <div class="table-body">
                            <div class="columns">
                                {% for column in table.columns %}
                                <span class="column">{{ column }}</span>
                                {% endfor %}
                            </div>
                            <a href="/table/{{ table.name }}" class="btn">View Data</a>
                        </div>
                    </div>
                    {% endfor %}
                </div>
            </div>
            
            <button class="refresh-btn" onclick="location.reload()">🔄</button>
        </body>
        </html>
        """
        
        # Calculate stats
        total_records = sum(table['count'] for table in table_info)
        
        try:
            db_size = f"{os.path.getsize(DB_PATH) / 1024 / 1024:.1f} MB"
        except:
            db_size = "Unknown"
        
        current_time = datetime.now().strftime("%H:%M:%S")
        
        return render_template_string(
            html_template,
            table_info=table_info,
            total_records=total_records,
            db_size=db_size,
            current_time=current_time
        )
    
    @app.route('/table/<table_name>')
    def view_table(table_name):
        """View table data"""
        page = request.args.get('page', 1, type=int)
        per_page = 50
        offset = (page - 1) * per_page
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Get table schema
        cursor.execute(f"PRAGMA table_info({table_name})")
        columns = [col['name'] for col in cursor.fetchall()]
        
        # Get total count
        cursor.execute(f"SELECT COUNT(*) as count FROM {table_name}")
        total_count = cursor.fetchone()['count']
        
        # Get data with pagination
        cursor.execute(f"SELECT * FROM {table_name} LIMIT {per_page} OFFSET {offset}")
        rows = cursor.fetchall()
        
        conn.close()
        
        # Convert rows to list of dicts
        data = []
        for row in rows:
            data.append(dict(row))
        
        total_pages = (total_count // per_page) + (1 if total_count % per_page > 0 else 0)
        
        html_template = """
        <!DOCTYPE html>
        <html lang="tr">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>{{ table_name }} - ustam Database</title>
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f5f5f5; }
                .header { background: #2563eb; color: white; padding: 1rem; }
                .header h1 { margin-bottom: 0.5rem; }
                .container { max-width: 1400px; margin: 2rem auto; padding: 0 1rem; }
                .nav { margin-bottom: 2rem; }
                .nav a { display: inline-block; padding: 0.5rem 1rem; background: #6b7280; color: white; text-decoration: none; border-radius: 4px; margin-right: 0.5rem; }
                .nav a:hover { background: #4b5563; }
                .table-container { background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
                .table-info { padding: 1rem; background: #f8fafc; border-bottom: 1px solid #e5e7eb; }
                table { width: 100%; border-collapse: collapse; }
                th, td { padding: 0.75rem; text-align: left; border-bottom: 1px solid #e5e7eb; }
                th { background: #f8fafc; font-weight: 600; position: sticky; top: 0; }
                tr:hover { background: #f8fafc; }
                .pagination { padding: 1rem; text-align: center; }
                .pagination a { display: inline-block; padding: 0.5rem 1rem; margin: 0 0.25rem; background: #e5e7eb; color: #374151; text-decoration: none; border-radius: 4px; }
                .pagination a.active { background: #2563eb; color: white; }
                .pagination a:hover { background: #d1d5db; }
                .cell-content { max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
                .json-cell { font-family: monospace; font-size: 0.875rem; }
            </style>
        </head>
        <body>
            <div class="header">
                <h1>📋 {{ table_name }}</h1>
                <p>{{ total_count }} total records</p>
            </div>
            
            <div class="container">
                <div class="nav">
                    <a href="/">← Back to Dashboard</a>
                    <a href="/table/{{ table_name }}">Refresh</a>
                </div>
                
                <div class="table-container">
                    <div class="table-info">
                        <strong>Showing {{ offset + 1 }}-{{ offset + data|length }} of {{ total_count }} records</strong>
                        (Page {{ page }} of {{ total_pages }})
                    </div>
                    
                    <table>
                        <thead>
                            <tr>
                                {% for column in columns %}
                                <th>{{ column }}</th>
                                {% endfor %}
                            </tr>
                        </thead>
                        <tbody>
                            {% for row in data %}
                            <tr>
                                {% for column in columns %}
                                <td>
                                    <div class="cell-content">
                                        {% set value = row[column] %}
                                        {% if value is none %}
                                            <em style="color: #9ca3af;">NULL</em>
                                        {% elif value is string and (value.startswith('{') or value.startswith('[')) %}
                                            <div class="json-cell">{{ value }}</div>
                                        {% else %}
                                            {{ value }}
                                        {% endif %}
                                    </div>
                                </td>
                                {% endfor %}
                            </tr>
                            {% endfor %}
                        </tbody>
                    </table>
                    
                    {% if total_pages > 1 %}
                    <div class="pagination">
                        {% if page > 1 %}
                            <a href="?page=1">First</a>
                            <a href="?page={{ page - 1 }}">Previous</a>
                        {% endif %}
                        
                        {% for p in range(max(1, page - 2), min(total_pages + 1, page + 3)) %}
                            <a href="?page={{ p }}" {% if p == page %}class="active"{% endif %}>{{ p }}</a>
                        {% endfor %}
                        
                        {% if page < total_pages %}
                            <a href="?page={{ page + 1 }}">Next</a>
                            <a href="?page={{ total_pages }}">Last</a>
                        {% endif %}
                    </div>
                    {% endif %}
                </div>
            </div>
        </body>
        </html>
        """
        
        return render_template_string(
            html_template,
            table_name=table_name,
            columns=columns,
            data=data,
            total_count=total_count,
            total_pages=total_pages,
            page=page,
            offset=offset
        )
    
    @app.route('/sql')
    def sql_query():
        """SQL query interface"""
        html_template = """
        <!DOCTYPE html>
        <html lang="tr">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>SQL Query - ustam Database</title>
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f5f5f5; }
                .header { background: #2563eb; color: white; padding: 1rem; }
                .container { max-width: 1200px; margin: 2rem auto; padding: 0 1rem; }
                .nav { margin-bottom: 2rem; }
                .nav a { display: inline-block; padding: 0.5rem 1rem; background: #6b7280; color: white; text-decoration: none; border-radius: 4px; margin-right: 0.5rem; }
                .query-form { background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
                textarea { width: 100%; height: 200px; padding: 1rem; border: 1px solid #d1d5db; border-radius: 4px; font-family: monospace; }
                .btn { padding: 0.75rem 1.5rem; background: #2563eb; color: white; border: none; border-radius: 4px; cursor: pointer; margin-top: 1rem; }
                .btn:hover { background: #1d4ed8; }
                .examples { margin-top: 2rem; }
                .example { background: #f8fafc; padding: 1rem; margin: 0.5rem 0; border-radius: 4px; font-family: monospace; cursor: pointer; }
                .example:hover { background: #f1f5f9; }
                .warning { background: #fef3c7; border: 1px solid #f59e0b; padding: 1rem; border-radius: 4px; margin-bottom: 2rem; }
            </style>
        </head>
        <body>
            <div class="header">
                <h1>🔍 SQL Query Interface</h1>
                <p>Execute custom SQL queries on the database</p>
            </div>
            
            <div class="container">
                <div class="nav">
                    <a href="/">← Back to Dashboard</a>
                </div>
                
                <div class="warning">
                    <strong>⚠️ Warning:</strong> This is a read-only interface for safety. Only SELECT queries are allowed.
                </div>
                
                <div class="query-form">
                    <form method="POST" action="/sql/execute">
                        <textarea name="query" placeholder="Enter your SQL query here...">SELECT * FROM users LIMIT 10;</textarea>
                        <button type="submit" class="btn">Execute Query</button>
                    </form>
                </div>
                
                <div class="examples">
                    <h3>📝 Example Queries</h3>
                    <div class="example" onclick="setQuery(this.textContent)">SELECT COUNT(*) FROM users WHERE user_type = 'craftsman';</div>
                    <div class="example" onclick="setQuery(this.textContent)">SELECT c.name, COUNT(j.id) as job_count FROM categories c LEFT JOIN jobs j ON c.id = j.category_id GROUP BY c.id;</div>
                    <div class="example" onclick="setQuery(this.textContent)">SELECT u.first_name, u.last_name, cr.business_name, cr.average_rating FROM users u JOIN craftsmen cr ON u.id = cr.user_id WHERE cr.is_verified = 1;</div>
                    <div class="example" onclick="setQuery(this.textContent)">SELECT status, COUNT(*) as count FROM jobs GROUP BY status;</div>
                </div>
            </div>
            
            <script>
                function setQuery(query) {
                    document.querySelector('textarea[name="query"]').value = query;
                }
            </script>
        </body>
        </html>
        """
        
        return render_template_string(html_template)
    
    return app

def main():
    """Run the database viewer"""
    print("🔨 ustam - DATABASE VIEWER")
    print("="*50)
    print("Starting web-based database viewer...")
    print("Open your browser and go to: http://localhost:5001")
    print("Press Ctrl+C to stop the server")
    print("="*50)
    
    app = create_viewer_app()
    app.run(host='0.0.0.0', port=5001, debug=True)

if __name__ == '__main__':
    main()