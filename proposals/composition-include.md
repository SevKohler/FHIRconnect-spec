# Spec proposal: Compositions are included into extensions, not their own layer

**Status:** Draft proposal
**Branch:** `composition-spec`
**Page:** `types-of-mapping-files/composition-element.adoc`

## Motivation

A Composition in openEHR has no direct FHIR equivalent — its fields (`date`,
`author`, `status`, participations, identifiers) land on the target resource
instance. Today each `COMPOSITION.<archetype>.<Resource>` model mapping carries
these composition-level fields, and the spec framed them as **inherited by the
model mapping and overwritten per project**.

That made the composition feel like a hidden, implicit layer. We want it
explicit.

## Change

Reframe the composition as a reusable mapping you **include** in your extension:

- A composition is **not a mapping file layer of its own**.
- An extension `extends` the composition mapping by its `metadata.name`, pulling
  in all its composition-level mappings.
- Untouched fields are used as-is; `overwrite` changes one, `add` extends it.

```yaml
type: extension
metadata:
  name: my_report
spec:
  system: FHIR
  version: R4
  extends: COMPOSITION.report-result.v1.Composition  # include the composition

mappings:
  - name: "date"
    extension: "overwrite"   # use the rest as-is, change what you need
    with:
      fhir: "$resource.date"
      openehr: "$composition/context/start_time"
```

## Open items

- Confirm the mechanism is the existing `extends` + `overwrite`/`add`, or whether
  a dedicated `include:` / `composition:` key is wanted instead.
