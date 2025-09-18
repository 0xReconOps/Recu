#!/usr/bin/env python3

"""
Python Jail Challenge (500 points)
==================================

A moderately secure Python sandbox with strategic vulnerabilities
that allow for escape through advanced Python techniques.

Goal: Read the flag from /opt/pyjail/flag.txt
"""

import sys
import ast
import types
import builtins

# ASCII Art Banner
BANNER = """
╔══════════════════════════════════════════════════════════════╗
║                    🐍 PYTHON JAIL CHALLENGE 🐍                ║
║                         500 POINTS                           ║
║                                                              ║
║  Your mission: Escape the Python sandbox and read the flag  ║
║  Flag location: /opt/pyjail/flag.txt                        ║
║                                                              ║
║  Some restrictions apply. Can you find the escape route?    ║
╚══════════════════════════════════════════════════════════════╝
"""

class PythonJail:
    """A Python jail with moderate security - 500 points difficulty"""
    
    def __init__(self):
        # Basic blacklist - blocks obvious attacks but allows bypass routes
        self.blacklist = [
            'import', 'exec', 'eval', 'compile', 'open', 
            '__import__', 'execfile', 'reload',
            'os.', 'sys.', 'subprocess.',
            'getattr', 'setattr', 'delattr',
            'globals(', 'locals(', 'vars(',
            'file(', 'input('
        ]
        
        # Create safe builtins (missing some key functions)
        self.safe_builtins = {
            'print': print,
            'len': len, 'str': str, 'int': int, 'float': float, 'bool': bool,
            'list': list, 'dict': dict, 'tuple': tuple, 'set': set,
            'range': range, 'enumerate': enumerate, 'zip': zip,
            'map': map, 'filter': filter, 'sorted': sorted, 'reversed': reversed,
            'sum': sum, 'min': min, 'max': max, 'abs': abs, 'round': round,
            'chr': chr, 'ord': ord, 'hex': hex, 'oct': oct, 'bin': bin,
            'repr': repr, 'type': type, 'isinstance': isinstance, 'all': all, 'any': any,
            'help': self.show_help,
        }
        
        # Restricted namespace
        self.namespace = {
            '__builtins__': self.safe_builtins,
        }
    
    def show_help(self):
        """Custom help function"""
        print("""
🔒 Python Jail Help:
- Many dangerous functions are blocked
- Try to find creative ways to access files
- Python's object model might be useful
- Think about class inheritance and method resolution
        """)
    
    def is_blocked(self, code):
        """Check if code contains blocked patterns"""
        code_lower = code.lower().replace(' ', '').replace('\n', '')
        
        # Check blacklist
        for blocked in self.blacklist:
            if blocked in code_lower:
                return True, f"Blocked pattern: {blocked}"
        
        # Block some obvious bypass attempts
        if 'builtins' in code_lower and ('__' in code_lower or 'getitem' in code_lower):
            return True, "Blocked: builtins access attempt"
            
        return False, ""
    
    def execute_code(self, code):
        """Execute code with restrictions"""
        try:
            # Check blacklist
            blocked, reason = self.is_blocked(code)
            if blocked:
                return f"❌ {reason}"
            
            # Parse and validate AST (basic validation)
            try:
                tree = ast.parse(code, '<string>', 'exec')
                
                # Block direct imports
                for node in ast.walk(tree):
                    if isinstance(node, (ast.Import, ast.ImportFrom)):
                        return "❌ Import statements not allowed"
            except SyntaxError as e:
                return f"❌ Syntax error: {e}"
            
            # Execute in restricted namespace
            from io import StringIO
            old_stdout = sys.stdout
            captured = StringIO()
            sys.stdout = captured
            
            try:
                exec(code, self.namespace)
                output = captured.getvalue()
                return output if output else "✅ Executed successfully"
            except Exception as e:
                return f"❌ Runtime error: {type(e).__name__}: {e}"
            finally:
                sys.stdout = old_stdout
                
        except Exception as e:
            return f"❌ Error: {e}"

def main():
    """Main jail interface"""
    print(BANNER)
    print("🔒 Welcome to the Python Jail!")
    print("📝 Enter Python code to execute. Type 'help' for assistance, 'exit' to quit.")
    print("🎯 Goal: Read the contents of /opt/pyjail/flag.txt")
    print("💡 Tip: Python's object model is very flexible...")
    print("-" * 65)
    
    jail = PythonJail()
    command_count = 0
    
    while True:
        try:
            command_count += 1
            
            # Get user input
            code = input(f"\n🐍 [{command_count}] pyjail> ")
            
            # Handle special commands
            if code.strip().lower() == 'exit':
                print("👋 Goodbye!")
                break
            elif code.strip().lower() == 'help':
                jail.show_help()
                continue
            elif code.strip().lower() == 'builtins':
                print("📋 Available functions:", sorted(jail.safe_builtins.keys()))
                continue
            elif code.strip() == '':
                continue
            
            # Execute the code
            result = jail.execute_code(code)
            print(result)
            
        except KeyboardInterrupt:
            print("\n\n👋 Interrupted. Goodbye!")
            break
        except EOFError:
            print("\n\n👋 EOF. Goodbye!")
            break

if __name__ == "__main__":
    main()
