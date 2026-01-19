#!/usr/bin/env python3
"""Run a simple two-sample t-test with normal approximation for p-value."""

import argparse
import csv
import math
from statistics import mean, variance


def normal_cdf(x: float) -> float:
    return 0.5 * (1.0 + math.erf(x / math.sqrt(2.0)))


def two_sided_p_value_from_z(z: float) -> float:
    return 2.0 * (1.0 - normal_cdf(abs(z)))


def load_metric(path: str):
    with open(path, encoding="utf-8") as file:
        reader = csv.DictReader(file)
        for row in reader:
            yield row["group"], float(row["metric"])


def t_test(control, test):
    mean_control = mean(control)
    mean_test = mean(test)
    var_control = variance(control)
    var_test = variance(test)
    n_control = len(control)
    n_test = len(test)

    # Welch's t-test statistic (no equal-variance assumption).
    numerator = mean_test - mean_control
    denominator = math.sqrt(var_control / n_control + var_test / n_test)
    t_stat = numerator / denominator

    # Use normal approximation for p-value to keep dependencies minimal.
    p_value = two_sided_p_value_from_z(t_stat)
    return t_stat, p_value, mean_control, mean_test


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

    print("Welch t-test (normal approximation)")
    print(f"n_control={len(control)}, n_test={len(test)}")
    print(f"mean_control={mean_control:.2f}, mean_test={mean_test:.2f}")
    print(f"uplift={uplift:.2%}")
    print(f"t_stat={t_stat:.3f}, p_value~={p_value:.4f}")


if __name__ == "__main__":
    main()
