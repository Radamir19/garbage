import ast
from pathlib import Path

import pytest
from hypothesis import given, settings, strategies as st
from calc import CalcException, calculate, opn


@pytest.mark.parametrize('expression', ['', ' ', ':', 'abc', '1 2', '1+',
                                          '0!0', '10^400', '0^(0-1)'])
def test_bad_inputs_use_public_exception(expression):
    with pytest.raises(CalcException):
        calculate(opn(expression))


@pytest.mark.parametrize(('expression', 'expected'), [
    ('0+0', 0), ('2+3*4', 14), ('(2+3)*4', 20),
    ('8/4', 2), ('7-12', -5), ('2^3', 8), ('0^0', 1),
    ('1/0', float('inf')),  # Original behavior, outside the failure criterion.
])
def test_calculation_results(expression, expected):
    assert calculate(opn(expression)) == expected


@settings(max_examples=1000, derandomize=True, database=None)
@given(a=st.integers(0, 1000), b=st.integers(0, 1000), c=st.integers(0, 1000))
def test_precedence_and_parentheses(a, b, c):
    assert calculate(opn(f'{a}+{b}*{c}')) == a + b * c
    assert calculate(opn(f'({a}+{b})*{c}')) == (a + b) * c


def test_opn_unchanged():
    original = ast.parse(Path('stages/00_original.py').read_text())
    current = ast.parse(Path('calc.py').read_text())
    functions = lambda tree: {n.name: ast.dump(n, include_attributes=False)
                              for n in tree.body if isinstance(n, ast.FunctionDef)}
    for name in ('opn', 'is_op', 'op_prior'):
        assert functions(original)[name] == functions(current)[name]
