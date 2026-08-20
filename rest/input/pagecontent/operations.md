# Operations

## $tofhir

Converts an openEHR Composition to FHIR resources.

**Endpoint:** `POST [base]/$tofhir`

The Composition may be supplied in either the flat or the canonical serialization.

### Input - Parameters resource

```json
{
  "resourceType": "Parameters",
  "parameter": [
    {
      "name": "composition",
      "valueString": "<stringified openEHR Composition JSON>"
    },
    {
      "name": "context",
      "part": [
        {
          "name": "ehr_id",
          "valueString": "53d89df2-5501-4455-9a65-565a5d1ddb7c"
        },
        {
          "name": "patient",
          "valueReference": {
            "reference": "Patient/123"
          }
        },
        {
          "name": "who",
          "valueReference": {
            "reference": "Practitioner/456"
          }
        },
        {
          "name": "onBehalfOf",
          "valueReference": {
            "reference": "Organization/charite"
          }
        }
      ]
    }
  ]
}
```

**Parameter notes:**

| Name                 | Required | Type                                              | Description                                                                                                                                                                                                                                                                                         |
|----------------------|----------|---------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `composition`        | yes      | string                                            | openEHR Composition as stringified JSON, flat or canonical                                                                                                                                                                                                                                          |
| `templateId`         | no       | string                                            | Pins the mapping to a specific context if more than one is applicable for this Composition                                                                                                                                                                                                          |
| `context`            | no       | -                                                 | Groups the context fields below as nested parts                                                                                                                                                                                                                                                     |
| `context.ehr_id`     | no       | string                                            | openEHR EHR identifier                                                                                                                                                                                                                                                                              |
| `context.patient`    | no       | Reference(Patient)                                | FHIR Patient to populate subject/patient references. A fallback for when the engine cannot resolve the subject itself - see "Resolving the patient" below |
| `context.who`        | no       | Reference(Practitioner \| Device \| Organization) | Overrides Provenance `agent.who`                                                                                                                                                                                                                                                                    |
| `context.onBehalfOf` | no       | Reference(Organization)                           | Institution the agent acts for; mapped to Provenance `agent.onBehalfOf`                                                                                                                                                                                                                             |

#### Resolving the patient

An openEHR Composition identifies the patient only indirectly, through the EHR it belongs to, so mapping to
FHIR requires resolving an EHR ID to a patient identity. The preferred arrangement is for the engine to
integrate with whatever service already owns patient identity in the deployment - a Master Patient Index, a
national or regional patient registry, or a demographics service - rather than expecting the caller to supply
it.

That integration is not always possible: there may be no such service, it may be unreachable from where the
engine runs, access may be constrained by governance or data-protection rules, or the engine may be running in
a test or offline context. `context.patient` exists for those cases, letting the caller state the subject
directly.

It is a fallback. An engine MUST NOT require it, and calls that omit it MUST still succeed wherever the engine
can resolve the subject by other means. When both are available, the supplied value takes precedence. Because
this bypasses the identity service, correctness rests with the caller - a wrong reference silently attaches
clinical data to the wrong patient.

### Output - FHIR Bundle

The response is a FHIR `Bundle`. The Bundle type is implementation-dependent. An `OperationOutcome` MAY be included as
an entry.

---

## $toopenehr

Converts a FHIR Bundle to an openEHR Composition.

**Endpoint:** `POST [base]/$toopenehr`

### Input - FHIR Bundle

The request body is a FHIR `Bundle` containing the resources to be converted.

| Name         | Required | Type   | Description                                                                                                                                                                               |
|--------------|----------|--------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bundle`     | yes      | Bundle | The FHIR Bundle containing the resources to be converted                                                                                                                                  |
| `templateId` | no       | string | Pins the mapping to a specific openEHR template (context), forcing a particular context mapping. When omitted, the engine matches the incoming resources against the context profile URLs |
| `format`     | no       | code   | Serialization of the returned Composition: `canonical` or `flat`. Defaults to `canonical`, which is what openEHR CDRs expect on commit                                                    |

### Output - Parameters resource

On success, the response contains only the `composition` parameter. The `format` input parameter selects its
serialization - `canonical` by default, or `flat`:

```json
{
  "resourceType": "Parameters",
  "parameter": [
    {
      "name": "composition",
      "valueString": "{\"_type\": \"COMPOSITION\", \"name\": {\"_type\": \"DV_TEXT\", \"value\": \"International Patient Summary\"}, ...}"
    }
  ]
}
```

#### OperationOutcome on partial mapping failure

When a mapping issue occurs - e.g. a source element could not be mapped, a required field was absent, or only a partial
result could be produced - an additional `return` parameter carrying an `OperationOutcome` SHOULD be included alongside
`composition`. The presence of an `OperationOutcome` does **not** imply the composition is absent; a partial result MAY
be returned together with issues describing what could not be mapped.

```json
{
  "resourceType": "Parameters",
  "parameter": [
    {
      "name": "composition",
      "valueString": "{\"_type\": \"COMPOSITION\", \"name\": {\"_type\": \"DV_TEXT\", \"value\": \"International Patient Summary\"}, ...}"
    },
    {
      "name": "outcome",
      "resource": {
        "resourceType": "OperationOutcome",
        "issue": [
          {
            "severity": "warning",
            "code": "incomplete",
            "details": {
              "text": "Element Observation.effectivePeriod could not be mapped; no corresponding openEHR archetype path found."
            }
          }
        ]
      }
    }
  ]
}
```

**Parameter notes:**

| Name          | Required | Type             | Description                                                                                                         |
|---------------|----------|------------------|---------------------------------------------------------------------------------------------------------------------|
| `composition` | yes      | string           | Resulting openEHR Composition as stringified JSON, in the serialization selected by `format` (canonical by default) |
| `outcome`     | no       | OperationOutcome | Present when mapping issues occurred; describes elements that could not be mapped or partial failures               |
