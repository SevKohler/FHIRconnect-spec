# FHIRConnect RESTful Implementation Guide

This Implementation Guide defines the REST API surface for a **FHIRConnect engine** — the FHIR facade layer that sits on top of the FHIRConnect mapping engine and exposes it as FHIR operations.

It is intentionally **separate from the FHIRConnect mapping specification** itself. Mapping rules, template bindings, and the `$context` variable semantics are specified in the [FHIRConnect specification](https://github.com/SevKohler/FHIRconnect-spec).

## Overview

Two FHIR operations are defined:

| Operation | Endpoint | Direction |
|---|---|---|
| [`$tofhir`](OperationDefinition-ToFhir.html) | `POST [base]/$tofhir` | openEHR Composition → FHIR Bundle |
| [`$toopenehr`](OperationDefinition-ToOpenEhr.html) | `POST [base]/$toopenehr` | FHIR Bundle → openEHR Composition |

Both operations follow the [FHIR Operations framework (R4)](https://hl7.org/fhir/R4/operations.html).

## Design Principles

- **Parameters in, Bundle out** for `$tofhir`; **Bundle in, Parameters out** for `$toopenehr`.
- The openEHR Composition is always carried as a JSON string (`valueString`) rather than a nested resource, for FHIR SDK compatibility.
- Context fields (patient reference, EHR ID, provenance agent) are passed alongside the composition as named Parameters entries.
- The output Bundle type (`collection`, `searchset`, `document`) is **not fixed** by this IG — it is context-dependent and left to the implementation.
- `OperationOutcome` entries MAY be included in the Bundle to convey warnings or partial mapping failures.
