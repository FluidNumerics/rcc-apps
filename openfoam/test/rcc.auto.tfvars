cluster_name = "<name>"
project = "research-computing-cloud"
zone = "us-central1-f"

suspend_time = 2

controller_image = "<image>"
disable_controller_public_ips = false
controller_machine_type = "n1-standard-16"
controller_disk_size_gb = 1024
controller_disk_type = "pd-ssd"

login_image = "<image>"
disable_login_public_ips = true
login_machine_type = "n1-standard-4"
login_node_count = 0


compute_node_scopes          = [
  "https://www.googleapis.com/auth/cloud-platform"
]
partitions = [
  { name                 = "c2-standard-60"
    machine_type         = "c2-standard-60"
    image                = "<image>"
    image_hyperthreads   = true
    static_node_count    = 0
    max_node_count       = 25
    zone                 = "<zone>"
    compute_disk_type    = "pd-standard"
    compute_disk_size_gb = 100
    compute_labels       = {}
    cpu_platform         = null
    gpu_count            = 0
    gpu_type             = null
    gvnic                = false
    network_storage      = []
    preemptible_bursting = false
    vpc_subnet           = null
    exclusive            = false
    enable_placement     = false
    regional_capacity    = false
    regional_policy      = null
    instance_template    = null
  },
  { name                 = "c2-standard-60-compact"
    machine_type         = "c2-standard-60"
    image                = "<image>"
    image_hyperthreads   = true
    static_node_count    = 0
    max_node_count       = 25
    zone                 = "<zone>"
    compute_disk_type    = "pd-standard"
    compute_disk_size_gb = 100
    compute_labels       = {}
    cpu_platform         = null
    gpu_count            = 0
    gpu_type             = null
    gvnic                = false
    network_storage      = []
    preemptible_bursting = false
    vpc_subnet           = null
    exclusive            = false
    enable_placement     = true
    regional_capacity    = false
    regional_policy      = null
    instance_template    = null
  },
  { name                 = "c2d-standard-112"
    machine_type         = "c2d-standard-112"
    image                = "<image>"
    image_hyperthreads   = true
    static_node_count    = 0
    max_node_count       = 25
    zone                 = "<zone>"
    compute_disk_type    = "pd-standard"
    compute_disk_size_gb = 100
    compute_labels       = {}
    cpu_platform         = null
    gpu_count            = 0
    gpu_type             = null
    gvnic                = false
    network_storage      = []
    preemptible_bursting = false
    vpc_subnet           = null
    exclusive            = false
    enable_placement     = false
    regional_capacity    = false
    regional_policy      = null
    instance_template    = null
  },
  { name                 = "c2d-standard-112-compact"
    machine_type         = "c2d-standard-112"
    image                = "<image>"
    image_hyperthreads   = true
    static_node_count    = 0
    max_node_count       = 25
    zone                 = "<zone>"
    compute_disk_type    = "pd-standard"
    compute_disk_size_gb = 100
    compute_labels       = {}
    cpu_platform         = null
    gpu_count            = 0
    gpu_type             = null
    gvnic                = false
    network_storage      = []
    preemptible_bursting = false
    vpc_subnet           = null
    exclusive            = false
    enable_placement     = true
    regional_capacity    = false
    regional_policy      = null
    instance_template    = null
  },
]
