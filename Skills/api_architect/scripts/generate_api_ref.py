import json
import os
import sys
import re
from jinja2 import Environment, FileSystemLoader

def generate_code_snippets(method, request_url_obj, body):
    if isinstance(request_url_obj, dict):
        url = request_url_obj.get('raw', '')
    else:
        url = str(request_url_obj)
        
    url = url.replace('{{baseUrl}}', 'https://api.github.com')
    
    curl_snippet = f"curl -L \\\n  -X {method} \\\n  -H \"Accept: application/vnd.github+json\" \\\n  -H \"Authorization: Bearer <YOUR-TOKEN>\""
    if url:
        curl_snippet += f" \\\n  {url}"
    if body and body != "{}":
        safe_body = body.replace("'", "'\\''")
        curl_snippet += f" \\\n  -d '{safe_body}'"
        
    python_snippet = "import requests\n\n"
    python_snippet += "headers = {\n"
    python_snippet += "  'Accept': 'application/vnd.github+json',\n"
    python_snippet += "  'Authorization': 'Bearer <YOUR-TOKEN>'\n"
    python_snippet += "}\n\n"
    if body and body != "{}":
        python_snippet += "import json\n\n"
        python_snippet += f"data = {body}\n\n"
        python_snippet += f"response = requests.{method.lower()}('{url}', headers=headers, data=json.dumps(data))\n"
    else:
        python_snippet += f"response = requests.{method.lower()}('{url}', headers=headers)\n"
    python_snippet += "print(response.json())"
    
    path = url.replace('https://api.github.com', '').strip()
    path_interpolated = re.sub(r':([a-zA-Z0-9_]+)', r'{\1}', path)

    js_snippet = "const { Octokit } = require(\"@octokit/rest\");\n"
    js_snippet += "const octokit = new Octokit({\n  auth: 'YOUR-TOKEN'\n});\n\n"
    js_snippet += f"await octokit.request('{method} {path_interpolated}', {{\n"
    js_snippet += "  headers: {\n"
    js_snippet += "    'X-GitHub-Api-Version': '2022-11-28'\n"
    js_snippet += "  }"
    if body and body != "{}":
        body_indented = body.replace('\n', '\n  ')
        js_snippet += f",\n  ...{body_indented}"
    js_snippet += "\n});"

    return {
        'curl': curl_snippet,
        'python': python_snippet,
        'javascript': js_snippet
    }

def extract_parameters(request_url):
    """
    Extract query parameters and path variables from Postman request url object.
    """
    params = []
    
    # Query parameters
    for q in request_url.get('query', []):
        params.append({
            'name': q.get('key'),
            'type': 'string', # Postman default to string for query
            'required': True if q.get('disabled') is not True else False,
            'description': q.get('description', 'No description.').replace('\n', '<br>').replace('\r', ''),
            'example': q.get('value', '')
        })
        
    # Path variables
    for v in request_url.get('variable', []):
        params.append({
            'name': f"{{{v.get('key')}}}",
            'type': 'string',
            'required': True, # Path variables are typically required
            'description': v.get('description', 'No description.').replace('\n', '<br>').replace('\r', ''),
            'example': v.get('value', '')
        })
        
    return params

def extract_body(request):
    """
    Extract request body (JSON) from Postman request object.
    """
    body = ""
    if 'body' in request and request['body'].get('mode') == 'raw':
        try:
            data = json.loads(request['body'].get('raw', '{}'))
            body = json.dumps(data, indent=2)
        except json.JSONDecodeError:
            body = request['body'].get('raw', '')
    return body

def extract_response(responses):
    """
    Extract successful response (status 200/201) from Postman response array.
    """
    for r in responses:
        if r.get('code') in [200, 201]:
            try:
                data = json.loads(r.get('body', '{}'))
                return json.dumps(data, indent=2)
            except json.JSONDecodeError:
                return r.get('body', '')
    return "{}"

def flatten_items(postman_items):
    """
    Recursively flatten Postman items to identify only requests.
    """
    requests = []
    for item in postman_items:
        if 'request' in item:
            requests.append(item)
        elif 'item' in item:
            requests.extend(flatten_items(item['item']))
    return requests

def generate_api_reference(collection_path, output_dir, template_dir):
    """
    Deterministic generation of API reference documentation.
    """
    env = Environment(loader=FileSystemLoader(template_dir))
    template = env.get_template('api_endpoint.md.j2')

    with open(collection_path, 'r', encoding='utf-8') as f:
        collection = json.load(f)

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for top_level_folder in collection.get('item', []):
        folder_name = top_level_folder['name']
        # Sanitize folder_name to be a safe filename
        file_basename = folder_name.lower().replace(' ', '-').replace('/', '-').replace('{', '').replace('}', '')
        
        # Identify endpoints in this folder and subfolders
        folder_items = flatten_items(top_level_folder.get('item', []))
        
        endpoints = []
        for item in folder_items:
            req = item['request']
            body_str = extract_body(req)
            
            raw_url = req.get('url', {}).get('raw', '') if isinstance(req.get('url'), dict) else str(req.get('url', ''))
            raw_url = re.sub(r':([a-zA-Z0-9_]+)', r'{\1}', raw_url)
            req['url']['raw'] = raw_url

            url_path = raw_url.replace('{{baseUrl}}', '').replace('https://api.github.com', '').split('?')[0].strip()

            endpoints.append({
                'name': item['name'],
                'method': req['method'],
                'url_path': url_path,
                'description': req.get('description', 'No description.'),
                'parameters': extract_parameters(req['url']),
                'request_body': body_str,
                'response_body': extract_response(item.get('response', [])),
                'snippets': generate_code_snippets(req['method'], req['url'], body_str),
                'notes': '' # Potential space for audit results
            })
            
        if endpoints:
            output_content = template.render(items=endpoints)
            output_path = os.path.join(output_dir, f"{file_basename}.md")
            
            # Ensure output directory exists (if nested folders were used)
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(f"# {folder_name} API\n\n")
                f.write(output_content)
            print(f"Generated: {output_path}")

if __name__ == "__main__":
    COLLECTION_PATH = 'GitHub Web API Reference.postman_collection.json'
    OUTPUT_DIR = 'docs/api-reference'
    TEMPLATE_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'resources')
    
    generate_api_reference(COLLECTION_PATH, OUTPUT_DIR, TEMPLATE_DIR)
