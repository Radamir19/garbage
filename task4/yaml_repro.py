
import yaml

print('PyYAML:', yaml.__version__, flush=True)
text = '!'
node = yaml.compose(text, Loader=yaml.SafeLoader)
print('Input:', repr(text), flush=True)
print('Parsed:', node, flush=True)

workaround = yaml.serialize(node, explicit_start=True)
print('With explicit_start=True:', repr(workaround), flush=True)
assert yaml.compose(workaround, Loader=yaml.SafeLoader).tag == node.tag
print('Workaround reparses successfully.', flush=True)
rendered = yaml.serialize(node)
print('Default serialization:', repr(rendered), flush=True)
print('Reparsing default output (fails):', flush=True)
yaml.compose(rendered, Loader=yaml.SafeLoader)
