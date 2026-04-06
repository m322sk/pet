#!/usr/bin/env python3
"""Run a simple two-sample t-test with normal approximation for p-value."""

import argparse
import csv
from statistics import mean
from scipy.stats import ttest_ind

def load_metric(path: str):
    with open(path, encoding="utf-8") as file:
        reader = csv.DictReader(file)
        for row in reader:
            yield row["group"], float(row["metric"])


def t_test(control, test):
    result = ttest_ind(test, control, equal_var=False, nan_policy="omit")
    mean_control = mean(control)
    mean_test = mean(test)
    return result.statistic, result.pvalue, mean_control, mean_test


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, help="CSV with columns group, metric")
    args = parser.parse_args()

    control = []
    test = []
    for group, metric in load_metric(args.input):
        if group == "control":
            control.append(metric)
        elif group == "test":
            test.append(metric)

    if not control or not test:
        raise SystemExit("Need both control and test groups in the input")

    t_stat, p_value, mean_control, mean_test = t_test(control, test)
    uplift = (mean_test / mean_control - 1.0) if mean_control else float("nan")

    print("Welch t-test")
    print(f"n_control={len(control)}, n_test={len(test)}")
    print(f"mean_control={mean_control:.4f}, mean_test={mean_test:.4f}")
    print(f"uplift={uplift:.2%}")
    print(f"t_stat={t_stat:.4f}, p_value={p_value:.6f}")


if __name__ == "__main__":
    main()

