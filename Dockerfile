FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    default-jdk \
    ncbi-blast+ \
    perl \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME="/usr/lib/jvm/default-java"
ENV NXF_HOME="/opt/nextflow"
ENV NXF_TEMP="/tmp"

# Install Nextflow 20.01.0 and pre-download its runtime dependencies
RUN curl -fsSL https://github.com/nextflow-io/nextflow/releases/download/v20.01.0/nextflow \
    -o /usr/local/bin/nextflow && \
    chmod 755 /usr/local/bin/nextflow && \
    nextflow -version && \
    chmod -R 755 /opt/nextflow && \
    chmod -R 777 /opt/nextflow/tmp

# Copy the full project to a fixed location
COPY . /usr/local/genotype_conversion_file_builder

# Make pipeline files readable and bin scripts executable, pre-build BLAST database
RUN chmod -R 755 /usr/local/genotype_conversion_file_builder && \
    makeblastdb -in /usr/local/genotype_conversion_file_builder/data/reference.fa -dbtype nucl

# Add pipeline bin to PATH
ENV PATH="/usr/local/genotype_conversion_file_builder/bin:${PATH}"

WORKDIR /data

ENV NXF_ANSI_LOG="false"

ENTRYPOINT ["nextflow", "run", "/usr/local/genotype_conversion_file_builder/main.nf"]
