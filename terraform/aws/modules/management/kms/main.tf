resource "aws_kms_key" "this" {
  count                   = var.enabled && length(var.alias_name) > 0 ? length(var.alias_name) : 0
  description             = var.description[count.index]
  deletion_window_in_days = var.deletion_window_in_days[count.index]
  enable_key_rotation     = var.enable_key_rotation[count.index]
  policy                  = var.policy
  tags                    = var.tags
}

resource "aws_kms_alias" "this" {
  count         = var.enabled && length(var.alias_name) > 0 ? length(var.alias_name) : 0
  name          = "alias/${var.alias_name[count.index]}"
  target_key_id = aws_kms_key.this[count.index].key_id

  depends_on = [
    aws_kms_key.this,
  ]
}