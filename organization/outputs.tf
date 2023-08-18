output "development_ou_arn" {
  value = aws_organizations_organizational_unit.development.arn
}

output "dev1_account_id" {
  value = aws_organizations_account.dev1.id
}

output "shared_development_account_id" {
  value = aws_organizations_account.shared_development.id
}
