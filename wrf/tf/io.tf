variable "cloudsql_enable_ipv4" {
  type = bool
  description = "Flag to enable external access to the cloudsql instance"
  default = false
}

variable "cloudsql_slurmdb" {
  type = bool
  description = "Boolean flag to enable (True) or disable (False) CloudSQL Slurm Database"
  default = false
}

variable "cloudsql_name" {
  type = string
  description = "Name of the cloudsql instance used to host the Slurm database, if cloudsql_slurmdb is set to true"
  default = "slurmdb"
}

variable "cloudsql_tier" {
  type = string
  description = "Instance type of the CloudSQL instance. See https://cloud.google.com/sql/docs/mysql/instance-settings for more options."
  default = "db-n1-standard-8"
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "compute_node_scopes" {
  description = "Scopes to apply to compute nodes."
  type        = list(string)
  default = [
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/logging.write"
  ]
}

variable "compute_node_service_account" {
  description = "Service Account for compute nodes."
  type        = string
  default     = null
}

variable "controller_machine_type" {
  description = "Machine type to use for the controller instance"
  type        = string
  default     = null
}

variable "controller_disk_type" {
  description = "Disk type (pd-ssd or pd-standard) for controller."
  type        = string
  default     = null
}

variable "controller_image" {
  description = "Slurm image to use for the controller instance"
  type        = string
  default     = "projects/fluid-cluster-ops/images/family/rcc-centos-7-v300"
}

variable "controller_instance_template" {
  description = "Instance template to use to create controller instance"
  type        = string
  default     = null
}

variable "controller_disk_size_gb" {
  description = "Size of disk for the controller."
  type        = number
  default     = 100
}

variable "controller_labels" {
  description = "Labels to add to controller instance. List of key key, value pairs."
  type        = any
  default     = null
}

variable "controller_secondary_disk" {
  description = "Create secondary disk mounted to controller node"
  type        = bool
  default     = false
}

variable "controller_secondary_disk_size" {
  description = "Size of disk for the secondary disk"
  default     = 100
}

variable "controller_secondary_disk_type" {
  description = "Disk type (pd-ssd or pd-standard) for secondary disk"
  default     = "pd-ssd"
}

variable "controller_scopes" {
  description = "Scopes to apply to the controller"
  type        = list(string)
  default     = ["https://www.googleapis.com/auth/cloud-platform"]
}

variable "controller_service_account" {
  description = "Service Account for the controller"
  type        = string
  default     = null
}

variable "disable_login_public_ips" {
  type    = bool
  default = true
}

variable "disable_controller_public_ips" {
  type    = bool
  default = true
}

variable "disable_compute_public_ips" {
  type    = bool
  default = true
}

variable "login_disk_type" {
  description = "Disk type (pd-ssd or pd-standard) for login nodes."
  type        = string
  default     = null
}

variable "login_disk_size_gb" {
  description = "Size of disk for login nodes."
  type        = number
  default     = 100
}

variable "login_image" {
  description = "Slurm image to use for login instances"
  type        = string
  default     = "projects/fluid-cluster-ops/images/family/rcc-centos-7-v300"
}

variable "login_instance_template" {
  description = "Instance template to use to creating login instances"
  type        = string
  default     = null
}

variable "login_labels" {
  description = "Labels to add to login instances. List of key key, value pairs."
  type        = any
  default     = null
}

variable "login_machine_type" {
  description = "Machine type to use for login node instances."
  type        = string
  default     = null
}

variable "login_network_storage" {
  description = "An array of network attached storage mounts to be configured on the login and controller instances."
  type = list(object({
    server_ip    = string,
    remote_mount = string,
    local_mount  = string,
    fs_type      = string,
  mount_options = string }))
  default = []
}

variable "login_node_scopes" {
  description = "Scopes to apply to login nodes."
  type        = list(string)
  default = [
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/logging.write"
  ]
}

variable "login_node_service_account" {
  description = "Service Account for compute nodes."
  type        = string
  default     = null
}

variable "login_node_count" {
  description = "Number of login nodes in the cluster"
  default     = 1
}

variable "munge_key" {
  description = "Specific munge key to use"
  default     = null
}

variable "jwt_key" {
  description = "Specific libjwt key to use"
  default     = null
}

variable "network_name" {
  default = null
  type    = string
}

variable "network_storage" {
  description = " An array of network attached storage mounts to be configured on all instances."
  type = list(object({
    server_ip    = string,
    remote_mount = string,
    local_mount  = string,
    fs_type      = string,
  mount_options = string }))
  default = []
}

variable "partitions" {
  description = "An array of configurations for specifying multiple machine types residing in their own Slurm partitions."
  type = list(object({
    name                 = string,
    machine_type         = string,
    max_node_count       = number,
    zone                 = string,
    image                = string,
    image_hyperthreads   = bool,
    compute_disk_type    = string,
    compute_disk_size_gb = number,
    compute_labels       = any,
    cpu_platform         = string,
    gpu_type             = string,
    gpu_count            = number,
    gvnic                = bool,
    network_storage = list(object({
      server_ip    = string,
      remote_mount = string,
      local_mount  = string,
      fs_type      = string,
    mount_options = string })),
    preemptible_bursting = bool,
    vpc_subnet           = string,
    exclusive            = bool,
    enable_placement     = bool,
    regional_capacity    = bool,
    regional_policy      = any,
    instance_template    = string,
  static_node_count = number }))
}

variable "project" {
  type = string
}

variable "shared_vpc_host_project" {
  type    = string
  default = null
}

variable "subnetwork_name" {
  description = "The name of the pre-defined VPC subnet you want the nodes to attach to based on Region."
  default     = null
  type        = string
}

variable "suspend_time" {
  description = "Idle time (in sec) to wait before nodes go away"
  default     = 300
}

variable "zone" {
  type = string
}

variable "create_filestore" {
  type = bool
  description = "Boolean for controlling filestore creation (useful for optional modules)"
  default = false
}

variable "filestore" {
  type = object({
    name = string
    zone = string
    tier = string
    capacity_gb = number
    fs_name = string
    network = string
  })
  default = {
    name = "filestore"
    zone = null
    tier = "PREMIUM"
    capacity_gb = 2048
    fs_name = "nfs"
    network = null
  }
}

variable "create_lustre" {
  type = bool
  description = "Boolean for controlling lustre creation (useful for optional modules)"
  default = false
}
variable "lustre" {
  type = object({
    image = string
    project = string
    zone = string
    vpc_subnet = string
    service_account = string
    network_tags = list(string)
    name = string
    fs_name = string
    mds_node_count = number
    mds_machine_type = string
    mds_boot_disk_type = string
    mds_boot_disk_size_gb = number
    mdt_disk_type = string
    mdt_disk_size_gb = number
    mdt_per_mds = number
    oss_node_count = number
    oss_machine_type = string
    oss_boot_disk_type = string
    oss_boot_disk_size_gb = number
    ost_disk_type = string
    ost_disk_size_gb = number 
    ost_per_oss = number
    hsm_node_count = number
    hsm_machine_type = string
    hsm_gcs_bucket = string
    hsm_gcs_prefix = string
  })
  default = {
    image = "projects/research-computing-cloud/global/images/family/lustre"
    project = null
    zone = null
    vpc_subnet = null
    service_account = null
    network_tags = []
    name = "lustre-gcp"
    fs_name = "lustre"
    mds_node_count = 1
    mds_machine_type = "n2-standard-16"
    mds_boot_disk_type = "pd-standard"
    mds_boot_disk_size_gb = 100
    mdt_disk_type = "pd-ssd"
    mdt_disk_size_gb = 1024
    mdt_per_mds = 1
    oss_node_count = 2
    oss_machine_type = "n2-standard-16" 
    oss_boot_disk_type = "pd-standard"
    oss_boot_disk_size_gb = 100
    ost_disk_type = "local-ssd"
    ost_disk_size_gb = 1500 
    ost_per_oss = 1
    hsm_node_count = 0
    hsm_machine_type = "n2-standard-16"
    hsm_gcs_bucket = null
    hsm_gcs_prefix = null
  }
}
