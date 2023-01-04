# The following are "globals" and constant variables
# related to laser digital AWS organisation accounts
# These will be used everywhere in terraform codebase
locals {
  org_accounts = {
    master    = "111111111111"
    sre       = "222222222222"
    dev       = "555555555555"
    stg       = "666666666666"
    qa        = "777777777777"
    prod      = "888888888888"
  }

}