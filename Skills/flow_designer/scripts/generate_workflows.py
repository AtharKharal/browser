import yaml
import os
from jinja2 import Environment, FileSystemLoader

def generate_workflow(flow_path, template_dir):
    """
    Generate sequential documentation for developer workflows.
    """
    env = Environment(loader=FileSystemLoader(template_dir))
    template = env.get_template('workflow_step.md.j2')
    
    with open(flow_path, 'r') as f:
        flow = yaml.safe_load(f)
    
    steps = flow.get('steps', [])
    content = ""
    for step in steps:
        content += template.render(step=step) + "\n"
    
    return content

if __name__ == "__main__":
    print("Flow Designer Apparatus initialized.")
