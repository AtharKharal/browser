import os
import argparse
from jinja2 import Environment, FileSystemLoader

def generate_config(template_type, output_path, **kwargs):
    """
    Generate deterministic zensical.toml based on jinja2 template.
    """
    script_dir = os.path.dirname(os.path.abspath(__file__))
    resources_dir = os.path.join(os.path.dirname(script_dir), 'resources')
    
    # Map template type to filename
    template_map = {
        'sme_portal': 'sme_portal.toml.j2',
        'minimal': 'minimal_starter.toml.j2',
        'migration': 'migration_classic.toml.j2',
        'client': 'client_facing.toml.j2',
        'offline': 'offline_docs.toml.j2'
    }
    
    template_file = template_map.get(template_type)
    if not template_file:
        raise ValueError(f"Unknown template type. Available: {', '.join(template_map.keys())}")
        
    env = Environment(loader=FileSystemLoader(resources_dir))
    template = env.get_template(template_file)
    
    # Filter kwargs to remove None values
    render_args = {k: v for k, v in kwargs.items() if v is not None}
    
    content = template.render(**render_args)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(content)
        
    print(f"Success: Generated {output_path} successfully using '{template_type}' template.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Deterministic Zensical config generator")
    parser.add_argument('--template', required=True, choices=['sme_portal', 'minimal', 'migration', 'client', 'offline'],
                        help="The template type to use")
    parser.add_argument('--output', default='zensical.toml', help="Output file path")
    parser.add_argument('--site_name', help="Site name")
    parser.add_argument('--site_url', help="Site URL")
    parser.add_argument('--site_description', help="Site description")
    parser.add_argument('--site_author', help="Site author")
    parser.add_argument('--copyright_year', help="Copyright year")
    parser.add_argument('--copyright_holder', help="Copyright holder")
    parser.add_argument('--repo_url', help="Repository URL")
    parser.add_argument('--repo_name', help="Repository name")
    parser.add_argument('--analytics_property', help="Google Analytics ID")
    
    args = parser.parse_args()
    
    generate_config(
        args.template,
        args.output,
        site_name=args.site_name,
        site_url=args.site_url,
        site_description=args.site_description,
        site_author=args.site_author,
        copyright_year=args.copyright_year,
        copyright_holder=args.copyright_holder,
        repo_url=args.repo_url,
        repo_name=args.repo_name,
        analytics_property=args.analytics_property
    )
