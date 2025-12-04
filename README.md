
<p align="center">
    <img src="modules/ROOT/assets/images/FHIRconnect-logo.png" alt="FHIRconnect logo" width="250"/>
</p>


## DISCLAIMER!
FHIRconnect is the result of a research project. To support our research,
please cite one of our papers instead of referencing our github in scientific 
articles. You can find an overview of papers about FHIRconnect here. If you 
are not sure which paper to cite, we recommend this one:

[Kohler, S., Piera Jiménez, J., Anywar, M., Fuhrmann, L., Leslie, H., Meixner, M., Saß, J., Kärcher, F., Boscá, D., Haarbrandt, B., Marschollek, M., & Eils, R. (2025). FHIRconnect: Towards a seamless integration of openEHR and FHIR. arXiv:2511.14618.](https://arxiv.org/abs/2511.14618)

Thanks!

# How to access the specification
[FHIRconnect specification](https://sevkohler.github.io/FHIRconnect-spec/)

# Description
[FHIRconnect](https://sevkohler.github.io/FHIRconnect-spec/) is a YAML-based mapping language designed to bidirectionally transform data between openEHR and FHIR. It aims to be comprehensive, easy to use, and serves as both a transformation tool and documentation to ensure consistency across institutions. Even if vendors do not implement FHIRconnect, they can still refer to its specifications to understand how the transformation should be performed.

The official mapping library of FHIRconnect is maintained 
[here](https://github.com/SevKohler/FHIRconnect-mapping-lib/tree/main).

# How to build the spec

To build and run locally:
1. To build install antora
https://docs.antora.org/antora/latest/install/install-antora/
2. and install https://gitlab.com/antora/antora-lunr-extension

3. run inside the main folder:
npx antora antora-playbook.yml
