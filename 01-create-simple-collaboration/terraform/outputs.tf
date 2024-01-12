output "account_1_membership_id" {
  value = aws_cloudformation_stack.collab_membership_account_1.outputs.MembershipId
}

output "account_2_membership_id" {
  value = aws_cloudformation_stack.collab_membership_account_2.outputs.MembershipId
}
