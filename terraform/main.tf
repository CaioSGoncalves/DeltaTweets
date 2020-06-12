provider "google" {
  credentials = "${file("../key_file.json")}"
  project = "sincere-bongo-264115"
  region  = "southamerica-east1"
  zone    = "southamerica-east1-b"
}

provider "google-beta" {
  credentials = "${file("../key_file.json")}"
  project = "sincere-bongo-264115"
  region  = "southamerica-east1"
  zone    = "southamerica-east1-b"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "n1-standard-2"

  metadata_startup_script = "${file("./vm_startup.sh")}"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
      size = 20
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}


resource "google_storage_bucket_object" "kafka_ingestion_job" {
  name   = "movie_ratings/jobs/kafka_ingestion.py"
  source = "../jobs/kafka_ingestion.py"
  bucket = "teste-caio"
}

resource "google_storage_bucket_object" "daily_job" {
  name   = "movie_ratings/jobs/daily_job.py"
  source = "../jobs/daily_job.py"
  bucket = "teste-caio"
}

resource "google_storage_bucket_object" "zeppelin_init" {
  name   = "movie_ratings/zeppelin_init.sh"
  source = "./zeppelin_init.sh"
  bucket = "teste-caio"
}

resource "google_storage_bucket_object" "streaming_cluster_startup" {
  name   = "movie_ratings/streaming_cluster_startup.sh"
  source = "./streaming_cluster_startup.sh"
  bucket = "teste-caio"
}

resource "google_dataproc_cluster" "streaming-cluster" {
  name   = "streaming-cluster"
  region = "southamerica-east1"

  cluster_config {
    staging_bucket = "staging.sincere-bongo-264115.appspot.com"

    master_config {
        num_instances = 1
        machine_type  = "n1-standard-1"
        disk_config {
          boot_disk_type    = "pd-standard"
          boot_disk_size_gb = 100
        }
    }

    software_config {
      image_version = "1.4-debian9"
      override_properties = {
        "dataproc:dataproc.allow.zero.workers" = "true"
      }
    }

    gce_cluster_config {
      service_account_scopes = [
        "useraccounts-ro",
        "storage-rw",
        "logging-write",
        "cloud-platform"
      ]
    }

    initialization_action {
        script      = "gs://teste-caio/movie_ratings/streaming_cluster_startup.sh"
        timeout_sec = 500
    }

  }

  depends_on = [
    google_storage_bucket_object.streaming_cluster_startup,
  ]
  
}

resource "google_dataproc_cluster" "playground-cluster" {
  provider = "google-beta"
  name   = "playground-cluster"
  region = "southamerica-east1"

  cluster_config {
    staging_bucket = "staging.sincere-bongo-264115.appspot.com"

    master_config {
        num_instances = 1
        machine_type  = "n1-standard-2"
        disk_config {
          boot_disk_type    = "pd-standard"
          boot_disk_size_gb = 100
        }
    }

    software_config {
      image_version = "1.4-debian9"
      override_properties = {
        "dataproc:dataproc.allow.zero.workers" = "true"
      }
      optional_components = [ "ZEPPELIN" ]
    }

    endpoint_config {
      enable_http_port_access = "true"
    }

    initialization_action {
        script      = "gs://teste-caio/movie_ratings/zeppelin_init.sh"
        timeout_sec = 500
    }

  }

  depends_on = [
    google_storage_bucket_object.zeppelin_init,
  ]

}