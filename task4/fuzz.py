from hypothesis import given, note, settings, strategies as st
from calc import CalcException, calculate, opn


@given(st.text())
@settings(max_examples=100_000, deadline=None, report_multiple_bugs=False,
          derandomize=True, database=None)
def test_calculate_with_processed_input(input_string):
    try:
        processed_input = opn(input_string)
    except Exception:
        # opn is outside the scope of this assignment.
        return
    note(f'Input: {input_string!r}; RPN: {processed_input!r}')
    try:
        calculate(processed_input)
    except CalcException:
        pass


# Structured expressions reach arithmetic that arbitrary Unicode rarely reaches.
@settings(max_examples=10_000, deadline=None, derandomize=True, database=None)
@given(a=st.integers(0, 100), b=st.integers(0, 100),
       operator=st.sampled_from(["+", "-", "*", "/", "^", "!"]))
def test_binary_expressions(a, b, operator):
    expression = f"{a}{operator}{b}"
    try:
        calculate(opn(expression))
    except CalcException:
        pass


@settings(max_examples=1000, deadline=None, derandomize=True, database=None)
@given(a=st.integers(10, 100), b=st.integers(400, 1000))
def test_large_powers(a, b):
    try:
        calculate(opn(f"{a}^{b}"))
    except CalcException:
        pass


@settings(max_examples=1000, deadline=None, derandomize=True, database=None)
@given(b=st.integers(1, 1000))
def test_zero_negative_power(b):
    try:
        calculate(opn(f"0^(0-{b})"))
    except CalcException:
        pass
