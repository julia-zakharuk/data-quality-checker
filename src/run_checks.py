"""Run the SQL data quality checks and write a Markdown report.

Checks live in sql/checks.sql. A check passes when its query returns no rows.
"""

import argparse
import os
import re
import sys
import time
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import LiteralString, cast

import psycopg
from dotenv import load_dotenv
from psycopg import sql
from psycopg.rows import DictRow, dict_row

ROOT = Path(__file__).resolve().parents[1]
CHECKS_FILE = ROOT / "sql" / "checks.sql"
REPORT_FILE = ROOT / "reports" / "dq_report.md"
SAMPLE_SIZE = 5


@dataclass
class Check:
    name: str
    kind: str
    description: str
    query: str


@dataclass
class Result:
    check: Check
    failed: int
    examples: list[DictRow]
    seconds: float

    @property
    def passed(self) -> bool:
        return self.failed == 0


def parse_checks(path: Path) -> list[Check]:
    """Split the checks file into Check objects using the '-- check:' headers."""
    text = path.read_text(encoding="utf-8")
    chunks = re.split(r"^-- check:", text, flags=re.MULTILINE)[1:]
    checks = []
    for chunk in chunks:
        header, _, rest = chunk.partition("\n")
        name, kind, description = (part.strip() for part in header.split("|", 2))
        # Keep everything before the closing semicolon; this drops the section
        # comments that sit between checks.
        statement, separator, _ = rest.rpartition(";")
        query = statement if separator else rest
        checks.append(Check(name, kind, description, query.strip()))
    return checks


def as_sql(text: str) -> sql.SQL:
    # The queries come from the repository's own checks file, not from user input.
    return sql.SQL(cast(LiteralString, text))


def run_check(cur: psycopg.Cursor[DictRow], check: Check) -> Result:
    started = time.perf_counter()
    query = as_sql(check.query)

    cur.execute(sql.SQL("SELECT count(*) AS n FROM (\n{}\n) AS failed").format(query))
    row = cur.fetchone()
    failed = row["n"] if row else 0

    examples: list[DictRow] = []
    if failed:
        cur.execute(
            sql.SQL("SELECT * FROM (\n{}\n) AS failed LIMIT {}").format(
                query, sql.Literal(SAMPLE_SIZE)
            )
        )
        examples = cur.fetchall()

    return Result(check, failed, examples, time.perf_counter() - started)


def format_row(row: DictRow) -> str:
    return ", ".join(f"{key}={str(value)[:60]}" for key, value in row.items())


def print_result(result: Result) -> None:
    status = "PASS" if result.passed else "FAIL"
    print(
        f"[{status}] {result.check.name:<44} "
        f"{result.failed:>9,} rows  ({result.seconds:.2f}s)"
    )


def build_report(results: list[Result], generated_at: datetime) -> str:
    failed = [r for r in results if not r.passed]
    summary = (
        f"Generated: {generated_at:%Y-%m-%d %H:%M} | Checks: {len(results)} | "
        f"Passed: {len(results) - len(failed)} | Failed: {len(failed)}"
    )
    lines = [
        "# Data quality report",
        "",
        summary,
        "",
        "## Summary",
        "",
        "| Status | Check | Type | Failed rows |",
        "|---|---|---|---:|",
    ]
    for r in results:
        status = "PASS" if r.passed else "FAIL"
        lines.append(f"| {status} | `{r.check.name}` | {r.check.kind} | {r.failed:,} |")

    if failed:
        lines += ["", "## Failed checks"]
        for r in failed:
            lines += [
                "",
                f"### `{r.check.name}`",
                "",
                f"{r.check.description}. Failed rows: {r.failed:,}. Examples:",
                "",
                "```text",
                *(format_row(example) for example in r.examples),
                "```",
            ]
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Run SQL data quality checks and write a report."
    )
    parser.add_argument(
        "--strict", action="store_true", help="exit with code 1 if any check fails"
    )
    args = parser.parse_args()

    load_dotenv()
    checks = parse_checks(CHECKS_FILE)
    results: list[Result] = []

    with (
        psycopg.connect(
            host=os.getenv("DB_HOST"),
            port=os.getenv("DB_PORT"),
            dbname=os.getenv("DB_NAME"),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD"),
        ) as conn,
        conn.cursor(row_factory=dict_row) as cur,
    ):
        for check in checks:
            result = run_check(cur, check)
            print_result(result)
            results.append(result)

    REPORT_FILE.parent.mkdir(exist_ok=True)
    REPORT_FILE.write_text(build_report(results, datetime.now()), encoding="utf-8")

    failed = sum(not r.passed for r in results)
    print(f"\n{len(results)} checks: {len(results) - failed} passed, {failed} failed")
    print(f"Report written to {REPORT_FILE.relative_to(ROOT)}")
    return 1 if args.strict and failed else 0


if __name__ == "__main__":
    sys.exit(main())