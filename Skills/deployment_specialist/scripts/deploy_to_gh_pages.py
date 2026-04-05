import subprocess
import sys
import os

def run_command(command):
    """
    Execute a shell command deterministically.
    """
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error executing command: {command}")
        print(result.stderr)
        return False
    return True

def deploy():
    """
    Deploy the documentation to GitHub Pages.
    """
    print("Starting Deployment Specialist Apparatus...")
    
    # 1. Build the site
    if not run_command(".\\.venv\\Scripts\\python -m mkdocs build"):
        sys.exit(1)
    
    # 2. Check for Git Repository
    if not os.path.exists(".git"):
        print("Git repository not found. Initializing...")
        run_command("git init -b main")

    # 3. Deploy
    print("Publishing to GitHub Pages...")
    if not run_command(".\\.venv\\Scripts\\python -m mkdocs gh-deploy --force"):
        print("Deployment failed. Ensure you have push access to the repository.")
        sys.exit(1)
    
    print("Documentation successfully deployed to GitHub Pages.")

if __name__ == "__main__":
    deploy()
