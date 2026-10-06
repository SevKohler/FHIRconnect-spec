Instance: ToOpenEhr
InstanceOf: OperationDefinition
Usage: #definition
* name = "ToOpenEhr"
* title = "$toopenehr — Convert FHIR Bundle to openEHR Composition"
* status = #draft
* kind = #operation
* description = """
Converts a FHIR Bundle to an openEHR Composition using a FHIRConnect mapping.

The operation accepts a FHIR Bundle as input and returns a FHIR Parameters resource
containing the serialized openEHR Composition as a JSON string.

When the mapping is fully successful the response contains only the `composition` parameter.
When mapping issues occur (e.g. a source element could not be mapped, a required field was
absent, or a partial result was produced), an additional `outcome` parameter carrying an
`OperationOutcome` resource SHOULD be included alongside the `composition`. The presence of
an `OperationOutcome` does not necessarily mean the composition is absent — a partial result
MAY be returned together with issues describing what could not be mapped.

Example response with OperationOutcome:

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
"""
* affectsState = false
* code = #toopenehr
* system = true
* type = false
* instance = false

// ---- input parameters ----

* parameter[+]
  * name = #bundle
  * use = #in
  * min = 1
  * max = "1"
  * documentation = "The FHIR Bundle containing the resources to be converted to an openEHR Composition."
  * type = #Bundle

* parameter[+]
  * name = #templateId
  * use = #in
  * min = 0
  * max = "1"
  * documentation = "Pins the mapping to a specific openEHR template, forcing a particular context mapping. When omitted, the engine selects a context mapping by matching the incoming resources against the context profile URLs."
  * type = #string

* parameter[+]
  * name = #format
  * use = #in
  * min = 0
  * max = "1"
  * documentation = "The serialization of the returned openEHR Composition: 'canonical' or 'flat'. Defaults to 'canonical', which is the form openEHR CDRs expect when a Composition is committed."
  * type = #code

// ---- output parameters ----

* parameter[+]
  * name = #composition
  * use = #out
  * min = 1
  * max = "1"
  * documentation = "The resulting openEHR Composition serialized as a JSON string, in the serialization selected by the 'format' input parameter (canonical by default)."
  * type = #string

* parameter[+]
  * name = #outcome
  * use = #out
  * min = 0
  * max = "*"
  * documentation = "An OperationOutcome conveying warnings or partial mapping failures."
  * type = #OperationOutcome
