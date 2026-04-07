import ast
import os
import json
import argparse
from collections import defaultdict

class LexisAnalyzer(ast.NodeVisitor):
    """
    Analyzes Python source code to extract functional logic and dependencies
    without LLM intervention, ensuring 100% deterministic structural mapping.
    """
    def __init__(self):
        self.logic_map = {
            "functions": [],
            "classes": [],
            "dependencies": defaultdict(list),
            "invariants": []
        }

    def visit_ClassDef(self, node):
        methods = [n.name for n in node.body if isinstance(n, ast.FunctionDef)]
        self.logic_map["classes"].append({
            "name": node.name,
            "lineno": node.lineno,
            "methods": methods
        })
        self.generic_visit(node)

    def visit_FunctionDef(self, node):
        func_info = {
            "name": node.name,
            "args": [arg.arg for arg in node.args.args],
            "lineno": node.lineno,
            "calls": []
        }
        # Detect logic patterns (Invariants)
        for item in node.body:
            if isinstance(item, ast.If):
                # Basic representation of a business rule/branch
                func_info["calls"].append("conditional_branch")
        
        self.logic_map["functions"].append(func_info)
        self.generic_visit(node)

    def visit_Import(self, node):
        for alias in node.names:
            self.logic_map["dependencies"]["external"].append(alias.name)

    def visit_ImportFrom(self, node):
        self.logic_map["dependencies"]["internal"].append(node.module)

def scan_repository(path):
    if not os.path.exists(path):
        raise ValueError(f"The provided path '{path}' does not exist.")

    analyzer = LexisAnalyzer()
    
    # Check if a single file was passed
    if os.path.isfile(path):
        if path.endswith(".py"):
            with open(path, "r", encoding="utf-8") as f:
                try:
                    tree = ast.parse(f.read())
                    analyzer.visit(tree)
                except Exception as e:
                    print(f"Warning: Failed to parse {path}: {e}")
        return analyzer.logic_map

    # Process directory recursively
    for root, _, files in os.walk(path):
        # Exclude specific directories like venv, .git, node_modules, etc
        if any(exclude in root.split(os.sep) for exclude in ['.git', 'venv', 'node_modules', '__pycache__', '.pytest_cache']):
            continue

        for file in files:
            if file.endswith(".py"):
                file_path = os.path.join(root, file)
                with open(file_path, "r", encoding="utf-8") as f:
                    try:
                        tree = ast.parse(f.read())
                        analyzer.visit(tree)
                    except SyntaxError:
                        print(f"Warning: SyntaxError encountered parsing {file_path}. Skipping.")
                        continue
                    except UnicodeDecodeError:
                        print(f"Warning: Encoding issue with {file_path}. Skipping.")
                        continue
    return analyzer.logic_map

def main():
    parser = argparse.ArgumentParser(description="Deterministic AST Logic Extractor")
    parser.add_argument("--repo-path", "-r", required=True, help="Path to the repository (or file) to parse")
    parser.add_argument("--output", "-o", default="code_logic_map.json", help="Output JSON file path")
    
    args = parser.parse_args()
    
    try:
        repo_data = scan_repository(args.repo_path)
    except Exception as e:
        print(f"Error scanning repository: {e}")
        return

    # Ensure output dir exists if specified
    out_dir = os.path.dirname(args.output)
    if out_dir and not os.path.exists(out_dir):
        os.makedirs(out_dir)

    with open(args.output, "w", encoding="utf-8") as f:
        json.dump(repo_data, f, indent=2)
        
    print(f"Success: Logic map extracted and saved to {args.output}")

if __name__ == "__main__":
    main()