Instance: ToFhir
InstanceOf: OperationDefinition
Usage: #definition
* name = "ToFhir"
* title = "$tofhir — Convert openEHR Composition to FHIR"
* status = #draft
* kind = #operation
* description = """
Converts an openEHR Composition to one or more FHIR resources using a FHIRConnect mapping.

The operation accepts a FHIR Parameters resource containing the serialized openEHR Composition
and optional context fields (patient reference, EHR ID, provenance agent). It returns a FHIR Bundle
containing the mapped resources. The Bundle type is implementation-dependent
(collection, searchset, or document) and is not fixed by this specification.

An OperationOutcome MAY be included in the returned Bundle to convey warnings or partial failures.
"""
* affectsState = false
* code = #tofhir
* system = true
* type = false
* instance = false

// ---- input parameters ----

* parameter[+]
  * name = #composition
  * use = #in
  * min = 1
  * max = "1"
  * documentation = "The openEHR Composition serialized as a JSON string, in either the flat (simSDT) or the canonical serialization. Passed as valueString rather than resource to maintain FHIR SDK compatibility."
  * type = #string

* parameter[+]
  * name = #templateId
  * use = #in
  * min = 0
  * max = "1"
  * documentation = "Pins the mapping to a specific openEHR template. Particularly relevant when several context mappings exist for the same template or profile. Required when the composition is supplied in the flat serialization, which does not carry its template inline."
  * type = #string

* parameter[+]
  * name = #context
  * use = #in
  * min = 0
  * max = "1"
  * documentation = "Groups the context fields the engine needs but that are not part of the Composition itself (EHR ID, patient reference, provenance agent)."
  * part[+]
    * name = #ehr_id
    * use = #in
    * min = 0
    * max = "1"
    * documentation = "The openEHR EHR identifier associated with the Composition."
    * type = #string
  * part[+]
    * name = #patient
    * use = #in
    * min = 0
    * max = "1"
    * documentation = "Reference to the FHIR Patient resource that is the subject of the Composition. Used to populate subject/patient references in mapped resources."
    * type = #Reference
    * targetProfile = Canonical(http://hl7.org/fhir/StructureDefinition/Patient)
  * part[+]
    * name = #who
    * use = #in
    * min = 0
    * max = "1"
    * documentation = "Overrides the Provenance agent.who. When omitted the engine defaults to its own Device reference."
    * type = #Reference
    * targetProfile[+] = Canonical(http://hl7.org/fhir/StructureDefinition/Practitioner)
    * targetProfile[+] = Canonical(http://hl7.org/fhir/StructureDefinition/Device)
    * targetProfile[+] = Canonical(http://hl7.org/fhir/StructureDefinition/Organization)
  * part[+]
    * name = #onBehalfOf
    * use = #in
    * min = 0
    * max = "1"
    * documentation = "The institution the agent acts for, mapped to Provenance agent.onBehalfOf."
    * type = #Reference
    * targetProfile = Canonical(http://hl7.org/fhir/StructureDefinition/Organization)

// ---- output parameters ----

* parameter[+]
  * name = #return
  * use = #out
  * min = 1
  * max = "1"
  * documentation = """
A Bundle containing the FHIR resources produced by the mapping. The Bundle type
(collection, searchset, or document) is context-dependent. An OperationOutcome
MAY be included as an entry to convey warnings or partial mapping failures.
"""
  * type = #Bundle
