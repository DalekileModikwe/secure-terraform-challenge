# Coding Policy

## Purpose

This repository provisions a secure AWS workload foundation with Terraform. It should stay understandable during review, easy to extend, and safe to operate in multiple workload accounts.

## Required Reading

- `README.md`
- `FAQ.md`
- `docs/nfr-coverage.md`
- This document

## Architectural Rules

- Prefer reusable modules over root-level duplication.
- Avoid hardcoded values inside modules. If a value must have a default, expose it as an input with a useful description.
- Keep naming consistent with `{project-name}-{resource-type-name}-{environment-name}-{provider-alias-name}-{optional-name-descriptors}-{index}`.
- Keep the root module focused on composition and environment wiring.

## Terraform Input Rules

- Every input variable must include a helpful description.
- Descriptions should include practical example values where that improves usability.
- Use variable validation whenever Terraform can reject bad input early.
- Mark truly sensitive variables with `sensitive = true`.

## Comment Rules

Comments should explain why a control exists, what tradeoff was made, and which constraint forced the code shape. Comments should not repeat obvious Terraform syntax.

## Review Standard

A change is not ready unless names follow the agreed convention, variable descriptions and validations are useful, comments explain the non-obvious parts, docs still match the code, and `terraform fmt` plus `terraform validate` pass.
