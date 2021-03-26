# Azure Environment
variable adminUserName { default = "xadmin" }
variable adminPassword { default = "2018F5Networks!!" }
variable adminPubKey { default = "~/.ssh/id_rsa.pub" }
variable location { default = "usgovvirginia" }
variable region { default = "USGov Virginia" }
variable prefix { default = "mjc" }

variable instanceType {
  type = map(string)
  default = {
    "host" = "Standard_DS3_v2"
  }
}

variable region_domain { default = "usgovvirginia.cloudapp.usgovcloudapi.net" }

# https://www.open-scap.org/security-policies/choosing-policy/
variable oscap_profile { default = "https://security-metadata.canonical.com/oval/com.ubuntu.$(lsb_release -cs).usn.oval.xml.bz2" }
variable lsb_release { default = "bionic" }

# NETWORK
variable cidr { default = "10.100.0.0/16" }
variable subnets {
  type = map(string)
  default = {
    "management" = "10.100.0.0/24"
    "data_ext"   = "10.100.1.0/24"
    "data_int"   = "10.100.2.0/24"
  }
}

# mgmt private ips
variable nginx01mgmt { default = "10.100.0.4" }

variable tags {
  default = {
    "purpose"     = "public"
    "environment" = "f5env" #ex. dev/staging/prod
    "owner"       = "michael@f5.com"
    "group"       = "f5group"
    "costcenter"  = "f5costcenter"
    "application" = "f5app"
  }
}