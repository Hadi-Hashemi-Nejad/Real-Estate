resource "aws_ecr_repository" "my_ecr" {
  name                 = "my_ecr_repo"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "null_resource" "docker_packaging" {
	
	  provisioner "local-exec" {
	    command = <<EOF
	    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com
	    gradle build -p my_ecr_repo
	    docker build -t "${aws_ecr_repository.my_ecr.repository_url}:bayut_api_calls" -f .Images/Image_Bayut_API/Dockerfile .
		echo "starting docker push"
	    docker push "${aws_ecr_repository.my_ecr.repository_url}:bayut_api_calls"
		echo "finished docker push for bayut api caller image"
	    docker build -t "${aws_ecr_repository.my_ecr.repository_url}:DLD_downloader" -f .Images/Image_DLD_Download/Dockerfile .
		echo "starting docker push"
	    docker push "${aws_ecr_repository.my_ecr.repository_url}:dld_download"
		echo "finished docker push"
	    EOF
	  }
	

	  triggers = {
	    "run_at" = timestamp()
	  }
	

	  depends_on = [
	    aws_ecr_repository.my_ecr,
	  ]
}     

data "aws_caller_identity" "current" {}