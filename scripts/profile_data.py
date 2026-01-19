#!/usr/bin/env python3
"""Generate a lightweight data quality report for the cashback dataset."""

import csv
from collections import Counter, defaultdict
from pathlib import Path

DATA_PATH = Path("tinkoff2_cashback.csv")
REPORT_PATH = Path("docs/data_quality_report.md")


def load_rows():
    with DATA_PATH.open(encoding="utf-8") as file:
        reader = csv.DictReader(file)
        for row in reader:
            yield row


def main() -> None:
    rows = list(load_rows())
    if not rows:
        raise SystemExit("CSV is empty")

    total_rows = len(rows)
    fields = rows[0].keys()

    # Count missing values per column.
    missing = Counter()
    for row in rows:
        for field in fields:
            if row[field] == "":
                missing[field] += 1

    # Detect duplicate (client_id, month) keys.
    key_counts = Counter(
        (row["ключ_клиента"], row["месяц_покупок"]) for row in rows
    )
    duplicates = sum(1 for count in key_counts.values() if count > 1)

    # Simple stats for numeric-like columns (ratio of numeric values).
    numeric_ratio = defaultdict(float)
    for field in fields:
        numeric_values = 0
        for row in rows:
            value = row[field]
            if value == "":
                continue
            try:
                float(value)
                numeric_values += 1
            except ValueError:
                pass
        numeric_ratio[field] = numeric_values / total_rows

    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with REPORT_PATH.open("w", encoding="utf-8") as report:
        report.write("# Data Quality Report\n\n")
        report.write(f"Rows: {total_rows}\n\n")
        report.write("## Missing values\n")
        report.write("| Column | Missing | Missing % |\n")
        report.write("| --- | --- | --- |\n")
        for field in fields:
            miss = missing[field]
            report.write(
                f"| {field} | {miss} | {miss / total_rows:.2%} |\n"
            )
        report.write("\n## Duplicate keys\n")
        report.write(f"Duplicate (client_id, month) keys: {duplicates}\n\n")
        report.write("## Numeric ratio\n")
        report.write("Share of rows with numeric values (proxy for cleanliness):\n\n")
        report.write("| Column | Numeric ratio |\n")
        report.write("| --- | --- |\n")
        for field in fields:
            report.write(f"| {field} | {numeric_ratio[field]:.2%} |\n")


if __name__ == "__main__":
    main()
