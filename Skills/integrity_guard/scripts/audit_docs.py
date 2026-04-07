import difflib
import sys

def audit_docs(source_artifact, docs_artifact):
    """
    Enforce high-precision diffing between source and documentation.
    """
    with open(source_artifact, 'r', encoding='utf-8') as s:
        source_content = s.read()
    with open(docs_artifact, 'r', encoding='utf-8') as d:
        docs_content = d.read()

    # High-precision diff logic
    if source_content != docs_content:
        diff = difflib.unified_diff(
            docs_content.splitlines(),
            source_content.splitlines(),
            fromfile='Documentation',
            tofile='Source',
            lineterm=''
        )
        print("Consistency Audit Failed!")
        for line in diff:
            print(line)
        sys.exit(1)
    else:
        print("Consistency Audit Passed.")
        sys.exit(0)

if __name__ == "__main__":
    print("Integrity Guard Apparatus initialized.")
