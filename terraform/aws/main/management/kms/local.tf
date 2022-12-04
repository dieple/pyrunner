locals {

  kms_data = {

    sre = {
      alias_name = [
        "rds-${terraform.workspace}",
        "parameter-store-key-${terraform.workspace}",
        "lambda-key-${terraform.workspace}",
        "trade-data-${terraform.workspace}",
        "influxdb-${terraform.workspace}",
        "elasticsearch-${terraform.workspace}",
        "defi-${terraform.workspace}",
        "s3-${terraform.workspace}",
      ]
      deletion_window_in_days = [
        10,
        10,
        10,
        10,
        10,
        10,
        10,
        10,
      ]
      description = [
        "${terraform.workspace} rds kms keys",
        "${terraform.workspace} param store key",
        "${terraform.workspace} lambda key",
        "${terraform.workspace} trade data",
        "${terraform.workspace} influx db",
        "${terraform.workspace} elasticsearch",
        "${terraform.workspace} defi",
        "${terraform.workspace} s3",
      ]
      enable_key_rotation = [
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
      ]
      policy = data.aws_iam_policy_document.default.json
    },
    dev = {
      alias_name = [
        "rds-${terraform.workspace}",
        "parameter-store-key-${terraform.workspace}",
        "lambda-key-${terraform.workspace}",
        "trade-data-${terraform.workspace}",
        "influxdb-${terraform.workspace}",
        "elasticsearch-${terraform.workspace}",
        "defi-${terraform.workspace}",
        "s3-${terraform.workspace}",
      ]
      deletion_window_in_days = [
        10,
        10,
        10,
        10,
        10,
        10,
        10,
        10,
      ]
      description = [
        "${terraform.workspace} rds kms keys",
        "${terraform.workspace} param store key",
        "${terraform.workspace} lambda key",
        "${terraform.workspace} trade data",
        "${terraform.workspace} influx db",
        "${terraform.workspace} elasticsearch",
        "${terraform.workspace} defi",
        "${terraform.workspace} s3",
      ]
      enable_key_rotation = [
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
      ]
      policy = data.aws_iam_policy_document.default.json
    },
    prod = {
      alias_name = [
        "rds-${terraform.workspace}",
        "parameter-store-key-${terraform.workspace}",
        "lambda-key-${terraform.workspace}",
        "trade-data-${terraform.workspace}",
        "influxdb-${terraform.workspace}",
        "elasticsearch-${terraform.workspace}",
        "defi-${terraform.workspace}",
        "s3-${terraform.workspace}",
      ]
      deletion_window_in_days = [
        10,
        10,
        10,
        10,
        10,
        10,
        10,
      ]
      description = [
        "${terraform.workspace} rds kms keys",
        "${terraform.workspace} param store key",
        "${terraform.workspace} lambda key",
        "${terraform.workspace} trade data",
        "${terraform.workspace} influxdb",
        "${terraform.workspace} elasticsearch",
        "${terraform.workspace} defi",
        "${terraform.workspace} s3",
      ]
      enable_key_rotation = [
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
      ]
      policy = data.aws_iam_policy_document.default.json
    },
    qa = {
      alias_name = [
        "rds-${terraform.workspace}",
        "parameter-store-key-${terraform.workspace}",
        "lambda-key-${terraform.workspace}",
        "trade-data-${terraform.workspace}",
        "influx-${terraform.workspace}",
        "elasticsearch-${terraform.workspace}",
        "defi-${terraform.workspace}",
        "s3-${terraform.workspace}",
      ]
      deletion_window_in_days = [
        10,
        10,
        10,
        10,
        10,
        10,
        10,
        10,
      ]
      description = [
        "${terraform.workspace} rds kms keys",
        "${terraform.workspace} param store key",
        "${terraform.workspace} lambda key",
        "${terraform.workspace} trade data",
        "${terraform.workspace} influxdb",
        "${terraform.workspace} elasticsearch",
        "${terraform.workspace} defi",
        "${terraform.workspace} s3",
      ]
      enable_key_rotation = [
        false,
        false,
        false,
        false,
        false,
        false,
        false,
      ]
      policy = data.aws_iam_policy_document.default.json
    },
    defi-dev = {
      alias_name = [
        "rds-${terraform.workspace}",
        "parameter-store-key-${terraform.workspace}",
        "lambda-key-${terraform.workspace}",
        "trade-data-${terraform.workspace}",
        "influxdb-${terraform.workspace}",
        "elasticsearch-${terraform.workspace}",
        "defi-${terraform.workspace}",
        "s3-${terraform.workspace}",
      ]
      deletion_window_in_days = [
        10,
        10,
        10,
        10,
        10,
        10,
        10,
        10,
      ]
      description = [
        "${terraform.workspace} rds kms keys",
        "${terraform.workspace} param store key",
        "${terraform.workspace} lambda key",
        "${terraform.workspace} trade data",
        "${terraform.workspace} influx db",
        "${terraform.workspace} elasticsearch",
        "${terraform.workspace} defi",
        "${terraform.workspace} s3",
      ]
      enable_key_rotation = [
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
      ]
      policy = data.aws_iam_policy_document.default.json
    },
    coredev = {
      alias_name = [
        "rds-${terraform.workspace}",
        "parameter-store-key-${terraform.workspace}",
        "lambda-key-${terraform.workspace}",
        "trade-data-${terraform.workspace}",
        "influxdb-${terraform.workspace}",
        "elasticsearch-${terraform.workspace}",
        "defi-${terraform.workspace}",
        "s3-${terraform.workspace}",
      ]
      deletion_window_in_days = [
        10,
        10,
        10,
        10,
        10,
        10,
        10,
        10,
      ]
      description = [
        "${terraform.workspace} rds kms keys",
        "${terraform.workspace} param store key",
        "${terraform.workspace} lambda key",
        "${terraform.workspace} trade data",
        "${terraform.workspace} influx db",
        "${terraform.workspace} elasticsearch",
        "${terraform.workspace} defi",
        "${terraform.workspace} s3",
      ]
      enable_key_rotation = [
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
      ]
      policy = data.aws_iam_policy_document.default.json
    },

  }
}

