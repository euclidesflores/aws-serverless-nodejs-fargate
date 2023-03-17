output "ecr_arn" {
  value = aws_ecr_repository.app.arn
}

output "aws_ecr_repository" {
  value = aws_ecr_repository.app.repository_url
}

output "name" {
  value = aws_ecr_repository.app.id
}

output "repository_id" {
  value = aws_ecr_repository.app.registry_id
}

# output "aws_ecs_task_definition_arn" {
#   value = aws_ecs_task_definition.app.arn
# }