data "confluent_organization" "dapper_labs" {}

# Cloud Environment
data "confluent_environment" "dapper-sandbox" {
  id = "env-99mr0"
}

# Service Account
resource "confluent_service_account" "test-app-sa" {
  display_name = "${var.tag_name}-app-sa"
  description  = "Service Account for test app"
}

# API Key
resource "confluent_api_key" "app-manager-kafka-api-key" {
  display_name = "${var.tag_name}-app-manager-kafka-api-key"
  description  = "Kafka API Key that is owned by 'app-manager' service account"
  owner {
    id          = confluent_service_account.test-app-sa.id
    api_version = confluent_service_account.test-app-sa.api_version
    kind        = confluent_service_account.test-app-sa.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.basic.id
    api_version = confluent_kafka_cluster.basic.api_version
    kind        = confluent_kafka_cluster.basic.kind

    environment {
      id = data.confluent_environment.dapper-sandbox.id
    }
  }

  # The goal is to ensure that confluent_role_binding.app-manager-kafka-cluster-admin is created before
  # confluent_api_key.app-manager-kafka-api-key is used to create instances of
  # confluent_kafka_topic, confluent_kafka_acl resources.

  # 'depends_on' meta-argument is specified in confluent_api_key.app-manager-kafka-api-key to avoid having
  # multiple copies of this definition in the configuration which would happen if we specify it in
  # confluent_kafka_topic, confluent_kafka_acl resources instead.
  depends_on = [
    confluent_role_binding.test-app-manager-kafka-cluster-admin
  ]
}

# Access Control Lists
resource "confluent_kafka_acl" "describe-basic-cluster" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  resource_type = "CLUSTER"
  resource_name = "${var.tag_name}-kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.test-app-sa.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.basic.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

# Role Binding
resource "confluent_role_binding" "test-app-manager-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.test-app-sa.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.basic.rbac_crn
}

# Cluster
resource "confluent_kafka_cluster" "basic" {
  display_name = "${var.tag_name}_kafka_cluster"
  availability = "SINGLE_ZONE"
  cloud        = "GCP"
  region       = "us-central1"
  basic {}

  environment {
    id = data.confluent_environment.dapper-sandbox.id
  }
}

# Topic
resource "confluent_kafka_topic" "orders" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  topic_name       = "orders"
  partitions_count = 4
  rest_endpoint    = confluent_kafka_cluster.basic.rest_endpoint
  config = {
    "cleanup.policy"    = "compact"
    "max.message.bytes" = "12345"
    "retention.ms"      = "67890"
  }
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}
