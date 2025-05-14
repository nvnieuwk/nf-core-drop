process COUNTINGSUMMARY {
    tag "${meta.id}"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/3c/3c54f46cc4a1f9f92c216095525003cce5ad6581696086a76d9df45767d45a48/data' :
        'community.wave.seqera.io/library/bioconductor-genomicalignments_bioconductor-outrider_bioconductor-summarizedexperiment_r-base_pruned:a406dcdf0dae11ce' }"

    input:
    tuple val(meta), path(ods), path(coverage)

    output:
    tuple val(meta), path("*.html") , emit: txdb
    path  "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    template 'Summary.R'

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    #!/usr/bin/env Rscript
    a <- file("${prefix}.html", "w")
    close(a)

    ## VERSIONS FILE
    writeLines(
        c(
            '"${task.process}":',
            paste('    r-base:', strsplit(version[['version.string']], ' ')[[1]][3]),
            paste('    r-data.table:', as.character(packageVersion('data.table'))),
            paste('    r-ggplot2:', as.character(packageVersion('ggplot2'))),
            paste('    r-ggthemes:', as.character(packageVersion('ggthemes'))),
            paste('    r-cowplot:', as.character(packageVersion('cowplot'))),
            paste('    r-tidyr:', as.character(packageVersion('tidyr'))),
            paste('    bioconductor-genomicalignments:', as.character(packageVersion('GenomicAlignments'))),
            paste('    bioconductor-outrider:', as.character(packageVersion('OUTRIDER'))),
            paste('    bioconductor-summarizedexperiment:', as.character(packageVersion('SummarizedExperiment')))
        ),
    'versions.yml')
    """
}
