locals {
  segments = compact(concat(
    [
      var.project_name,
      var.resource_type_name,
      var.environment_name,
      var.provider_alias_name
    ],
    var.optional_descriptors,
    [var.index]
  ))

  normalized_segments = [
    for segment in local.segments :
    lower(replace(segment, "/[^a-zA-Z0-9-]/", "-"))
  ]
}
