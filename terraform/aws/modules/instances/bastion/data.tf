data "aws_region" "current" {}

data "null_data_source" "tags_as_list_of_maps" {
  count = length(keys(var.tags))

  inputs = tomap({
    "key"                 = element(keys(var.tags), count.index)
    "value"               = element(values(var.tags), count.index)
    "propagate_at_launch" = true
  })
}


