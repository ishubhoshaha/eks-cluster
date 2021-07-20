resource "aws_autoscaling_group" "asg" {
  depends_on                = [aws_launch_template.launch_template]
  name                      = "${local.env}-${local.project}-eks-worker-asg"
  max_size                  = local.max_worker_node
  min_size                  = local.min_worker_node
  desired_capacity          = local.min_worker_node
  default_cooldown          = "180"
  health_check_grace_period = "90"
  health_check_type         = "ELB"
  force_delete              = true
  termination_policies      = ["OldestInstance", "OldestLaunchTemplate"]
  vpc_zone_identifier       = [aws_subnet.private-subnet-1a.id, aws_subnet.private-subnet-1b.id, aws_subnet.private-subnet-1c.id]
  enabled_metrics           = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  tags = [
    {
      key                 = "Environment"
      value               = local.env
      propagate_at_launch = false
    },
    {
      key                 = "Project"
      value               = local.project
      propagate_at_launch = false
    },
    {
      key                 = "k8s.io/cluster-autoscaler/${local.env}-${local.project}-eks-cluster"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/enabled"
      value               = "true"
      propagate_at_launch = true
    }
  ]
  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.launch_template.id
        version            = "$Latest"
      }
      dynamic "override" {
        for_each = local.asg_mixed_instance_types
        content {
          instance_type     = local.asg_mixed_instance_types[override.key]["name"]
          weighted_capacity = local.asg_mixed_instance_types[override.key]["weight"]
        }
      }
    }
    instances_distribution {
      on_demand_base_capacity                  = "0"
      on_demand_allocation_strategy            = "prioritized"
      on_demand_percentage_above_base_capacity = local.on_demand_percentage_above_base_capacity
      spot_instance_pools                      = local.spot_instance_pools
      spot_allocation_strategy                 = local.spot_allocation_strategy
    }
  }
  lifecycle {
    ignore_changes        = [target_group_arns]
    create_before_destroy = true
  }
}

