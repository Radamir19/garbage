
from hypothesis import given, settings, strategies as st
import yaml


YAML_ALPHABET = (
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    ' \t\n\r-?:,[]{}#&*!|>\'"%@`._+/=\\'
    'абвгдеёжзийклмнопрстуфхцчшщъыьэюя'
)
YAML_TEXT = st.text(alphabet=YAML_ALPHABET, max_size=512)

PAYLOAD = st.text(alphabet='abcXYZ012 -_\n\t:[]{}#абвёя', max_size=40)
SCALARS = st.one_of(st.none(), st.booleans(), st.integers(),
                   st.floats(allow_nan=False, allow_infinity=False), PAYLOAD)
DATA = st.recursive(
    SCALARS,
    lambda child: st.one_of(st.lists(child, max_size=8),
                           st.dictionaries(PAYLOAD, child, max_size=8)),
    max_leaves=30,
)
FUZZ = settings(max_examples=10_000, deadline=None, derandomize=True, database=None)


@FUZZ
@given(YAML_TEXT)
def test_safe_load(text):
    try:
        yaml.safe_load(text)
    except yaml.YAMLError:

        pass


@FUZZ
@given(YAML_TEXT)
def test_compose(text):
    try:
        node = yaml.compose(text, Loader=yaml.SafeLoader)
    except yaml.YAMLError:
        return
    if node is not None:
        assert isinstance(node, yaml.nodes.Node)

        restored = yaml.compose(yaml.serialize(node), Loader=yaml.SafeLoader)
        assert type(restored) is type(node)
        assert restored.tag == node.tag


@FUZZ
@given(DATA)
def test_safe_dump(data):
    rendered = yaml.safe_dump(data, allow_unicode=True)
    assert yaml.safe_load(rendered) == data
