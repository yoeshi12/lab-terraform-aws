data "aws_iam_policy_document" "github_actions_app" {
  statement {
    sid = "AdministrarRolEC2DelLaboratorio"

    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:ListRoleTags",
      "iam:PassRole",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole"
    ]

    resources = [
      "arn:aws:iam::265808837027:role/lab-tf-2023100941-dev-*"
    ]
  }

  statement {
    sid = "AdjuntarSoloPoliticaSSM"

    actions = [
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy"
    ]

    resources = [
      "arn:aws:iam::265808837027:role/lab-tf-2023100941-dev-*"
    ]

    condition {
      test     = "ArnEquals"
      variable = "iam:PolicyARN"
      values = [
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      ]
    }
  }

  statement {
    sid = "LeerPoliticaSSMAdministrada"

    actions = [
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions"
    ]

    resources = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]
  }

  statement {
    sid = "AdministrarPerfilEC2DelLaboratorio"

    actions = [
      "iam:AddRoleToInstanceProfile",
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:GetInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:TagInstanceProfile",
      "iam:UntagInstanceProfile"
    ]

    resources = [
      "arn:aws:iam::265808837027:instance-profile/lab-tf-2023100941-dev-*",
      "arn:aws:iam::265808837027:role/lab-tf-2023100941-dev-*"
    ]
  }

  statement {
    sid = "AdministrarParametrosSSMDelLaboratorio"

    actions = [
      "ssm:AddTagsToResource",
      "ssm:DeleteParameter",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:ListTagsForResource",
      "ssm:PutParameter",
      "ssm:RemoveTagsFromResource"
    ]

    resources = [
      "arn:aws:ssm:us-east-2:265808837027:parameter/lab-tf-2023100941-dev/*"
    ]
  }
}

resource "aws_iam_role_policy" "terraform_app_minimo" {
  name   = "terraform-dev-app-minimo"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_actions_app.json
}
