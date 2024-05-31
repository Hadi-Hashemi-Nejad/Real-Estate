# Create ECR private repository to contain the docker images built
resource "aws_ecr_repository" "my_ecr" {
  name                 = "my_ecr_repo"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

# Creat variables and assign values to them
data "aws_caller_identity" "current" {} 
data "aws_region" "current" {}   
locals {
  aws_region  = "${data.aws_region.current.name}"
  ecr_reg   = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.aws_region}.amazonaws.com"
  ecr_repo  =   aws_ecr_repository.my_ecr.name
  image_tag_bayut = "bayut_ingestion"
  image_tag_dld = "dld_ingestion"

  dkr_bayut_img_src_path = "${path.module}/Images/Image_Bayut_API"
  dkr_bayut_img_src_sha256 = sha256(join("", [for f in fileset(".", "${local.dkr_bayut_img_src_path}/**") : file(f)]))

  dkr_dld_img_src_path = "${path.module}/Images/Image_DLD_Download"
  dkr_dld_img_src_sha256 = sha256(join("", [for f in fileset(".", "${local.dkr_dld_img_src_path}/**") : file(f)]))

  dkr_build_cmd_aws_profile = "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com"
  dkr_build_cmd_bayut_img_build = "docker build -t ${local.ecr_reg}/${local.ecr_repo}:${local.image_tag_bayut} -f ${local.dkr_bayut_img_src_path}/Dockerfile ."
  dkr_build_cmd_bayut_img_push = "docker push ${local.ecr_reg}/${local.ecr_repo}:${local.image_tag_bayut}"
  dkr_build_cmd_dld_img_build = "docker build -t ${local.ecr_reg}/${local.ecr_repo}:${local.image_tag_dld} -f ${local.dkr_dld_img_src_path}/Dockerfile ."
  dkr_build_cmd_dld_img_push = "docker push ${local.ecr_reg}/${local.ecr_repo}:${local.image_tag_dld}"

}
variable "force_image_rebuild" {
  type    = bool
  default = false # Turn this to true if you want the images to be created everytime (even without any changes made to them)
}

# build and push of docker image for bayut listings
resource "null_resource" "build_push_bayut_dkr_img" {
  triggers = {
    detect_docker_source_changes = var.force_image_rebuild == true ? timestamp() : local.dkr_bayut_img_src_sha256
  }
  provisioner "local-exec" {
    command = local.dkr_build_cmd_aws_profile
  }
  provisioner "local-exec" {
    command = local.dkr_build_cmd_bayut_img_build
  }
  provisioner "local-exec" {
    command = local.dkr_build_cmd_bayut_img_push
  }
}

# build and push of docker image for dld transactions
resource "null_resource" "build_push_dld_dkr_img" {
  triggers = {
    detect_docker_source_changes = var.force_image_rebuild == true ? timestamp() : local.dkr_dld_img_src_sha256
  }
  provisioner "local-exec" {
    command = local.dkr_build_cmd_aws_profile
  }
  provisioner "local-exec" {
    command = local.dkr_build_cmd_dld_img_build
  }
  provisioner "local-exec" {
    command = local.dkr_build_cmd_dld_img_push
  }
}