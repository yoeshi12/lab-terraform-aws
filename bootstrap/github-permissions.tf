data "aws_iam_policy_document" "github_actions_minimo" {
  statement {
    sid = "EstadoTerraformBucket"

    actions = [
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning",
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::tfstate-lab-265808837027-yosselyn"
    ]
  }

  statement {
    sid = "EstadoTerraformDev"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::tfstate-lab-265808837027-yosselyn/envs/dev/*"
    ]
  }

  statement {
    sid = "LecturaInfraestructura"

    actions = [
      "ec2:Describe*",
      "elasticloadbalancing:Describe*",
      "autoscaling:Describe*",
      "rds:Describe*",
      "rds:ListTagsForResource",
      "sts:GetCallerIdentity"
    ]

    resources = ["*"]
  }

  statement {
    sid = "LecturaAMI"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]

    resources = [
      "arn:aws:ssm:us-east-2::parameter/aws/service/ami-amazon-linux-latest/*"
    ]
  }

  statement {
    sid = "AdministrarRedYComputeDelLaboratorio"

    actions = [
      "ec2:AllocateAddress",
      "ec2:AssociateAddress",
      "ec2:AttachInternetGateway",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateInternetGateway",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateLaunchTemplateVersion",
      "ec2:CreateNatGateway",
      "ec2:CreateRoute",
      "ec2:CreateRouteTable",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSubnet",
      "ec2:CreateTags",
      "ec2:CreateVpc",
      "ec2:DeleteInternetGateway",
      "ec2:DeleteLaunchTemplate",
      "ec2:DeleteLaunchTemplateVersions",
      "ec2:DeleteNatGateway",
      "ec2:DeleteRoute",
      "ec2:DeleteRouteTable",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSubnet",
      "ec2:DeleteTags",
      "ec2:DeleteVpc",
      "ec2:DetachInternetGateway",
      "ec2:DisassociateAddress",
      "ec2:DisassociateRouteTable",
      "ec2:GetLaunchTemplateData",
      "ec2:ModifyLaunchTemplate",
      "ec2:ModifySubnetAttribute",
      "ec2:ModifyVpcAttribute",
      "ec2:ReleaseAddress",
      "ec2:ReplaceRoute",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress"
    ]

    resources = ["*"]
  }

  statement {
    sid = "AdministrarBalanceadorDelLaboratorio"

    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyListenerAttributes",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets"
    ]

    resources = ["*"]
  }

  statement {
    sid = "AdministrarAutoScalingDelLaboratorio"

    actions = [
      "autoscaling:AttachLoadBalancerTargetGroups",
      "autoscaling:CreateAutoScalingGroup",
      "autoscaling:CreateOrUpdateTags",
      "autoscaling:DeleteAutoScalingGroup",
      "autoscaling:DeleteTags",
      "autoscaling:DetachLoadBalancerTargetGroups",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup"
    ]

    resources = ["*"]
  }

  statement {
    sid = "AdministrarRDSDelLaboratorio"

    actions = [
      "rds:AddTagsToResource",
      "rds:CreateDBInstance",
      "rds:CreateDBSubnetGroup",
      "rds:DeleteDBInstance",
      "rds:DeleteDBSubnetGroup",
      "rds:ModifyDBInstance",
      "rds:ModifyDBSubnetGroup",
      "rds:RemoveTagsFromResource"
    ]

    resources = [
      "arn:aws:rds:us-east-2:265808837027:db:lab-tf-2023100941-dev-*",
      "arn:aws:rds:us-east-2:265808837027:subgrp:lab-tf-2023100941-dev-*"
    ]
  }
}

resource "aws_iam_role_policy" "terraform_minimo" {
  name   = "terraform-dev-minimo"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_actions_minimo.json
}
