# Operations

## $tofhir

Converts an openEHR Composition to FHIR resources.

**Endpoint:** `POST [base]/$tofhir`

### Input — Parameters resource

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
          "valueReference": { "reference": "Patient/123" }
        },
        {
          "name": "who",
          "valueReference": { "reference": "Practitioner/456" }
        },
        {
          "name": "onBehalfOf",
          "valueReference": { "reference": "Organization/charite" }
        },
        {
          "name": "policy",
          "valueUri": "http://example.org/policy/data-sharing"
        }
      ]
    }
  ]
}
```

**Parameter notes:**

| Name | Required | Type | Description |
|---|---|---|---|
| `composition` | yes | string | openEHR Composition as stringified JSON |
| `context` | no | — | Groups the context fields below as nested parts |
| `context.ehr_id` | no | string | openEHR EHR identifier |
| `context.patient` | no | Reference(Patient) | FHIR Patient to populate subject/patient references |
| `context.who` | no | Reference(Practitioner \| Device \| Organization) | Overrides Provenance `agent.who`; engine defaults to its own Device when omitted |
| `context.onBehalfOf` | no | Reference(Organization) | Institution the agent acts for; mapped to Provenance `agent.onBehalfOf` |
| `context.policy` | no | uri | Provenance policy URI; engine resolves remaining provenance data |

### Output — FHIR Bundle

The response is a FHIR `Bundle`. The Bundle type is implementation-dependent. An `OperationOutcome` MAY be included as an entry.

---

## $toopenehr

Converts a FHIR Bundle to an openEHR Composition.

**Endpoint:** `POST [base]/$toopenehr`

### Input — FHIR Bundle

The request body is a FHIR `Bundle` containing the resources to be converted.

### Output — Parameters resource

On success, the response contains only the `composition` parameter:

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

When a mapping issue occurs — e.g. a source element could not be mapped, a required field was absent, or only a partial result could be produced — an additional `return` parameter carrying an `OperationOutcome` SHOULD be included alongside `composition`. The presence of an `OperationOutcome` does **not** imply the composition is absent; a partial result MAY be returned together with issues describing what could not be mapped.

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

| Name | Required | Type | Description |
|---|---|---|---|
| `composition` | yes | string | Resulting openEHR Composition as stringified JSON |
| `outcome` | no | OperationOutcome | Present when mapping issues occurred; describes elements that could not be mapped or partial failures |
