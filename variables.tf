variable "aws_region" {
  description = "The AWS region things are created in"
}

variable "ec2_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "myEcsTaskExecutionRole"
}

variable "ecs_auto_scale_role_name" {
  description = "ECS auto scale role name"
  default     = "myEcsAutoScaleRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

# variable "app_image" {
#   description = "Docker image to run in the ECS cluster"
#   type        = string
# }

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  type        = number
}

variable "host_port" {
  description = "Port exposed to connect to the app"
  type        = number
}

variable "app_count" {
  description = "Number of docker containers to run"
  type        = number
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}
