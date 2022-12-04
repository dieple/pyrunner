resource "aws_iam_role" "bastion_role" {
  name = format("%s-%s", var.bastion_name, "role")

  assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": ["ec2.amazonaws.com"]
        },
        "Effect": "Allow"
      }
    ]
}
EOF
}

resource "aws_iam_role_policy" "bastion_role_policy" {
  name   = format("%s-%s", var.bastion_name, "role-policy")
  role   = aws_iam_role.bastion_role.id
  policy = data.aws_iam_policy_document.bastion_policy_document.json
}

resource "aws_iam_policy" "bastion_policy" {
  name   = format("%s-%s", var.bastion_name, "iam-policy")
  policy = data.aws_iam_policy_document.bastion_policy_document.json
}

resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = format("%s-%s", var.bastion_name, "instance-profile")
  path = "/"
  role = aws_iam_role.bastion_role.name
}

# Create the configuration for an ASG
resource "aws_launch_configuration" "as_conf" {
  name_prefix          = format("%s-%s", var.bastion_name, "lc")
  image_id             = var.ami_id
  instance_type        = var.instance_type
  security_groups      = var.security_groups
  iam_instance_profile = aws_iam_instance_profile.bastion_instance_profile.name
  enable_monitoring    = true
  key_name             = var.key_name

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type = "gp2"
    volume_size = var.volume_size
  }

  user_data = var.user_data
}

resource "aws_autoscaling_group" "bastion_asg" {
  name                      = format("%s-%s", var.bastion_name, "asg")
  vpc_zone_identifier       = var.public_subnets
  health_check_type         = "EC2"
  launch_configuration      = aws_launch_configuration.as_conf.name
  max_size                  = var.max_size
  min_size                  = var.min_size
  default_cooldown          = var.cooldown
  health_check_grace_period = var.health_check_grace_period
  desired_capacity          = var.desired_capacity
  termination_policies      = ["ClosestToNextInstanceHour", "OldestInstance", "Default"]
  enabled_metrics           = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  tags                      = data.null_data_source.tags_as_list_of_maps.*.outputs

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_schedule" "scale_up" {
  autoscaling_group_name = aws_autoscaling_group.bastion_asg.name
  scheduled_action_name  = "Scale Up"
  recurrence             = var.scale_up_cron
  min_size               = var.min_size
  max_size               = var.max_size
  desired_capacity       = var.desired_capacity
}

resource "aws_autoscaling_schedule" "scale_down" {
  autoscaling_group_name = aws_autoscaling_group.bastion_asg.name
  scheduled_action_name  = "Scale Down"
  recurrence             = var.scale_down_cron
  min_size               = var.scale_down_min_size
  max_size               = var.max_size
  desired_capacity       = var.scale_down_desired_capacity
}
