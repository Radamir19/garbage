# Домашнее задание 4

Для запуска нужен Python 3.10 или новее.

Создать окружение:

```sh
python -m venv .venv
```

Активировать в Windows PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

В Linux или macOS:

```sh
source .venv/bin/activate
```

Установить зависимости и запустить проверки:

```sh
python -m pip install -r requirements.txt
python -m pytest --hypothesis-show-statistics fuzz.py test_calc.py
python -m pytest --hypothesis-show-statistics fuzz_yaml.py
```

Исправлены 6 ошибок в `calculate`, написаны тесты Hypothesis. `opn` не менялся по логике. Проверки калькулятора проходят: 23 passed.

Для дополнительной части проверены три метода PyYAML. Найдена ошибка при повторном разборе сериализованного узла: 2 passed, 1 failed. Прогон занял около 3,5 минуты.

Отчёт — `REPORT.md`, вывод запусков — в `logs/`. Архив для сдачи — `task4_solution.zip` в корне репозитория.
