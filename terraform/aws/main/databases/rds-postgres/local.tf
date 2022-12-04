locals {
  rds_data = {
    coredev = {
      engine                                 = "aurora-postgresql"
      engine_version                         = "13.6"
      database_name                          = module.dbname_label.id
      name                                   = module.dbname_label.id
      cluster_identifier                     = module.tag_label.id
      vpc_id                                 = data.terraform_remote_state.vpc.outputs.vpc_id
      create_db_subnet_group                 = true
      create_security_group                  = true
      allowed_cidr_blocks                    = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
      iam_database_authentication_enabled    = true
      master_username                        = "postgres"
      master_password                        = random_password.master.result
      create_random_password                 = false
      apply_immediately                      = true
      skip_final_snapshot                    = true
      create_db_cluster_parameter_group      = true
      db_cluster_parameter_group_name        = format("%s-%s", module.tag_label.id, "cluster-pg")
      db_cluster_parameter_group_family      = "aurora-postgresql13"
      db_cluster_parameter_group_description = "Laser Digital rds postgres cluster parameter group"
      create_db_parameter_group              = true
      db_parameter_group_name                = format("%s-%s", module.tag_label.id, "cluster-pg")
      db_parameter_group_family              = "aurora-postgresql13"
      db_parameter_group_description         = "${module.tag_label.id} DB parameter group"
      enabled_cloudwatch_logs_exports        = ["postgresql"]
      kms_key_id                             = try(lookup(data.terraform_remote_state.kms.outputs.alias_map, "alias/rds-${terraform.workspace}", null))
      monitoring_interval                    = 60
      create_monitoring_role                 = true
      subnets                                = data.terraform_remote_state.vpc.outputs.private_subnets
      autoscaling_enabled                    = true
      autoscaling_min_capacity               = 1
      autoscaling_max_capacity               = 3
      preferred_backup_window                = "00:00-02:00"

      instances = {
        1 = {
          identifier = "writer-1"
          # instance_class = "db.r5.2xlarge"
          instance_class = "db.t3.medium"
        }
      }

      db_cluster_parameter_group_parameters = [
        {
          name         = "log_min_duration_statement"
          value        = 4000
          apply_method = "immediate"
        },
        {
          name         = "rds.force_ssl"
          value        = 1
          apply_method = "immediate"
        },
        {
          name         = "autovacuum_vacuum_cost_delay"
          value        = 0
          apply_method = "immediate"
        },
        {
          name         = "vacuum_cost_limit"
          value        = 10000
          apply_method = "immediate"
        },
        {
          name         = "autovacuum_vacuum_scale_factor"
          value        = "0.01"
          apply_method = "immediate"
        },
        {
          name         = "autovacuum_naptime"
          value        = 60
          apply_method = "immediate"
        }
      ]

      db_parameter_group_parameters = [
        {
          name         = "log_min_duration_statement"
          value        = 4000
          apply_method = "immediate"
        },
        {
          name         = "shared_preload_libraries"
          value        = "pg_stat_statements"
          apply_method = "immediate"
        },
        {
          name         = "log_lock_waits"
          value        = "on"
          apply_method = "immediate"
        },
        {
          name         = "idle_in_transaction_session_timeout"
          value        = "300000"
          apply_method = "immediate"
        },
        {
          name         = "pg_stat_statements.track_utility"
          value        = "on"
          apply_method = "immediate"
        },
        {
          name         = "random_page_cost"
          value        = "1.0"
          apply_method = "immediate"
        }
      ]
    },



  }
}

