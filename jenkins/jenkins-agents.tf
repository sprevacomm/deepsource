resource "docker_image" "base" {
  name = "${var.base_agent_repo}:latest"

  build {
    context = "${path.module}/agents/base"
    build_arg = {
      TERRAFORM : "True"
    }
    label = {
      author : "Terraform"
    }
    platform = "linux/amd64"
  }

  triggers = {
    dockerfile_sha1 = filesha1("${path.module}/agents/base/Dockerfile")
  }
}

resource "docker_registry_image" "base" {
  name          = docker_image.base.name
  keep_remotely = false

  triggers = {
    image_id = resource.docker_image.base.image_id
  }
}

resource "docker_image" "ruby" {
  name = "${var.ruby_agent_repo}:latest"

  build {
    context = "${path.module}/agents/ruby"
    build_arg = {
      TERRAFORM : "True"
    }
    label = {
      author : "Terraform"
    }
    platform = "linux/amd64"
  }

  triggers = {
    dockerfile_sha1 = filesha1("${path.module}/agents/ruby/Dockerfile")
  }
}

resource "docker_registry_image" "ruby" {
  name          = docker_image.ruby.name
  keep_remotely = false

  triggers = {
    image_id = resource.docker_image.ruby.image_id
  }
}

resource "docker_image" "react" {
  name = "${var.react_agent_repo}:latest"

  build {
    context = "${path.module}/agents/react"
    build_arg = {
      TERRAFORM : "True"
    }
    label = {
      author : "Terraform"
    }
    platform = "linux/amd64"
  }

  triggers = {
    dockerfile_sha1 = filesha1("${path.module}/agents/react/Dockerfile")
  }
}

resource "docker_registry_image" "react" {
  name          = docker_image.react.name
  keep_remotely = false

  triggers = {
    image_id = resource.docker_image.react.image_id
  }
}

resource "docker_image" "cypress" {
  name = "${var.cypress_agent_repo}:latest"

  build {
    context = "${path.module}/agents/cypress"
    build_arg = {
      TERRAFORM : "True"
    }
    label = {
      author : "Terraform"
    }
    platform = "linux/amd64"
  }

  triggers = {
    dockerfile_sha1 = filesha1("${path.module}/agents/cypress/Dockerfile")
  }
}

resource "docker_registry_image" "cypress" {
  name          = docker_image.cypress.name
  keep_remotely = false

  triggers = {
    image_id = resource.docker_image.cypress.image_id
  }
}
