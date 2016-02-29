backend "file" {
	path = "/var/vault/"
}

listener "tcp" {
	address = "0.0.0.0:8200"
	tls_disable = "true"
}

disable_mlock = true
