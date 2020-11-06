version 1.0

task CheckMetadata {
  input {
    Array[String] library
    Array[String] species
    Array[String] organ
  }

  command {
  python <<CODE

  library_set = set([ "~{sep='", "' library}" ])
  species_set = set([ "~{sep='", "' species}" ])
  organ_set = set([ "~{sep='", "' organ}" ])

  errors=0

  if len(library_set) != 1:
      print("ERROR: Library metadata is not consistent within the project.")
      errors += 1
  if len(species_set) != 1:
      print("ERROR: Species metadata is not consistent within the project.")
      errors += 1
  if len(organ_set) != 1:
      print("ERROR: Organ metadata is not consistent within the project.")
      errors += 1

  if errors > 0:
      raise ValueError("Files must have matching metadata in order to combine.")
  CODE
  }

  runtime {
      docker: "python:3.7.2"
      cpu: 1
      memory: "3 GiB"
      disks: "local-disk 20 HDD"
  }
}


task MergeLooms {
  input {
    Array[File] library_looms
    String library
    String species
    String organ
    String output_basename

    String docker = "quay.io/humancellatlas/secondary-analysis-loom-output:0.0.4-metadata-processing"
    Int memory = 3
    Int disk = 20
  }

  command {
    python3 optimus_HCA_loom_merge.py \
      --input-loom-files ~{sep=" " library_looms} \
      --library ~{library} \
      --species ~{species} \
      --organ ~{organ} \
      --output-loom-file ~{output_basename}.loom
  }

  runtime {
    docker: docker
    cpu: 1
    memory: "~{memory} GiB"
    disks: "local-disk ~{disk} HDD"
  }

  output {
    File project_loom = "~{output_basename}.loom"
  }
}


task CreateAdapterJson {
  input {
    File project_loom
    String document_id
    String submission_date
    String file_id
    String file_version
    String entity_id
    String output_basename

    Int memory = 3
    Int disk = 20
  }
  export sha=$(sha256sum ~{input_file} | cut -f1 -d ' ')
    export crc=$(gsutil hash -h ~{input_file_path} | awk '/crc32c/ { print $3 }')
    export size=$(gsutil stat ~{input_file_path} | awk '/Content-Length/ { print $2 }')

  command {
    export sha=$(sha256sum ~{input_file} | cut -f1 -d ' ')
    export crc=$(gsutil hash -h ~{input_file_path} | awk '/crc32c/ { print $3 }')
    export size=$(gsutil stat ~{input_file_path} | awk '/Content-Length/ { print $2 }')

    python3 HCA_create_adapter_json.py \
      --input-loom-file ~{project_loom} \

  }

  runtime {
    docker: "python:3.7.2" # TODO
    cpu: 1
    memory: "~{memory} GiB"
    disks: "local-disk ~{disk} HDD"
  }

  output {
    File project_loom = "~{output_basename}.loom"
  }
}