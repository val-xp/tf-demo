resource "databricks_sql_endpoint" "this" {
  name             = "VP warehouse"
  cluster_size     = "Small"
  max_num_clusters = 1

  tags {
    custom_tags {
      key   = "City"
      value = "Amsterdam"
    }
  }
}