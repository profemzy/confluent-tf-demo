locals {
  cluster_readers = ["reader"]
  cluster_writers = ["writer"]
  default_topic_config = {
    partitions = 12
    # Replication factor is required but cannot be changed
    replication_factor = 3
    config = {
      "cleanup.policy" = "delete"
    }
    acl_readers = local.cluster_readers
    acl_writers = local.cluster_writers
  }
}

module "demo_kafka" {
  source                  = "./confluent"
  environment             = "DEMO"
  gcp_region              = var.default_region
  name                    = "cruise"
  cku                     = 2
  availability            = "MULTI_ZONE"
  enable_metric_exporters = true
  topics = {
    "demo.wh.distribution-minted"              = local.default_topic_config,
    "demo.wh.distribution-updated"             = local.default_topic_config,
    "demo.wh.edition-minted"                   = local.default_topic_config,
    "demo.wh.edition-closed"                   = local.default_topic_config,
    "demo.wh.listing-available"                = local.default_topic_config,
    "demo.wh.listing-completed"                = local.default_topic_config,
    "demo.wh.minted-moment-nft"                = local.default_topic_config, //TODO: Remove this once updated
    "demo.wh.moment-nft-burned"                = local.default_topic_config,
    "demo.wh.moment-nft-minted"                = local.default_topic_config,
    "demo.wh.moment-nft-deposited"             = local.default_topic_config,
    "demo.wh.moment-nft-withdrawn"             = local.default_topic_config,
    "demo.wh.pack-nft-deposited"               = local.default_topic_config,
    "demo.wh.pack-nft-minted"                  = local.default_topic_config,
    "demo.wh.pack-nft-opened"                  = local.default_topic_config,
    "demo.wh.pack-nft-revealed"                = local.default_topic_config,
    "demo.wh.play-minted"                      = local.default_topic_config,
    "demo.wh.series-closed"                    = local.default_topic_config,
    "demo.wh.series-minted"                    = local.default_topic_config,
    "demo.wh.set-minted"                       = local.default_topic_config,
    "demo.wh.team-nft-deposited"               = local.default_topic_config,
    "demo.wh.team-nft-minted"                  = local.default_topic_config,
    "demo.wh.team-nft-series-created"          = local.default_topic_config,
    "demo.wh.team-nft-set-created"             = local.default_topic_config,
    "demo.wh.team-nft-series-metadata-updated" = local.default_topic_config,
    "demo.wh.team-nft-set-metadata-updated"    = local.default_topic_config,
  }
}
