# Домашнее задание 4: Hypothesis

Требуется Python 3.10+ (из-за `match`); проверено на Python 3.12.14.

```sh
python -m venv .venv
# Linux/macOS:
. .venv/bin/activate
# Windows PowerShell вместо предыдущей строки:
# .venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
python -m pytest --hypothesis-show-statistics fuzz.py
python -m pytest --hypothesis-show-statistics test_calc.py
python -m pytest --hypothesis-show-statistics fuzz_yaml.py
```

В `fuzz.py` основная цель принимает произвольный Unicode-текст, вызывает `opn`, затем `calculate`. Для `calculate` допустим только `CalcException`. Дополнительные структурированные генераторы достигают арифметических веток, куда случайный текст почти не попадает.

`logs/01_*.txt` — `logs/06_*.txt` содержат настоящие неуспешные запуски для шести ошибок; `logs/07_final_clean.txt` — итоговый прогон исправленной версии. `logs/yaml_research.txt` — отдельное исследование PyYAML. В каждом файле есть команда, вывод, код завершения и время. `run_capture.py` сохраняет вывод и возвращает код завершения pytest.

`stages/` содержит последовательные версии `calc.py` для воспроизведения старых ошибок. При воспроизведении используйте временную копию проекта: замените в ней `calc.py` нужным снимком и выполните команду из соответствующего лога. Исходник для первого запуска — `00_original.py`, для второго — `01_empty_fixed.py`, для третьего — `02_number_fixed.py`, для четвёртого — `03_index_fixed.py`, для пятого — `04_unsupported_fixed.py`, для шестого — `05_overflow_fixed.py`. `06_zero_power_fixed.py` совпадает с окончательным калькулятором. Номера строк в ранних логах отражают версии файлов на момент запуска.

Калькулятор проходит все 23 итоговых теста. В `fuzz_yaml.py` ожидается один реальный провал: найден дефект цепочки `compose → serialize → compose` на строке `!`. Минимальное независимое воспроизведение: `python yaml_repro.py` (код завершения 1); проверенный обход — `explicit_start=True` при сериализации.

Подробности результатов — в `REPORT.md`; разбор подозрительных мест — в `NEUROSLOP.md`; список скрытого белого текста PDF — в `PDF_HIDDEN_TEXT.txt`.

Для более длительного исследования PyYAML увеличьте `max_examples` в `fuzz_yaml.py` и запускайте с различными `--hypothesis-seed`. Реальное время каждого запуска фиксируйте отдельно; 30 минут в задании рекомендованы, но не являются выполненным здесь измерением.
