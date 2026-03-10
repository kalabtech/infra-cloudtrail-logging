data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# NOTE: Logical container for the Glue table - equivalent to a database schema in SQL
resource "aws_glue_catalog_database" "this" {
  name = lower("${var.project_name}_cloudtrail_${var.environment}")
}

# NOTE: Static table definition for CloudTrail logs stored in S3.
# No Crawler needed — CloudTrail schema is well-known and never changes.
resource "aws_glue_catalog_table" "this" {
  name          = "cloudtrail_logs"
  database_name = aws_glue_catalog_database.this.name

  table_type = "EXTERNAL_TABLE"

  # NOTE: Partition projection tells Athena how to navigate S3 paths by date
  # without scanning the entire bucket. Replaces manual partition management.
  parameters = {
    "classification"                     = "json"
    "projection.enabled"                 = "true"
    "projection.timestamp.type"          = "date"
    "projection.timestamp.format"        = "yyyy/MM/dd"
    "projection.timestamp.range"         = "2024/01/01,NOW"
    "projection.timestamp.interval"      = "1"
    "projection.timestamp.interval.unit" = "DAYS"
    "storage.location.template"          = "s3://${var.s3_bucket_id}/AWSLogs/${data.aws_caller_identity.current.account_id}/CloudTrail/${data.aws_region.current.name}/$${timestamp}"
  }

  storage_descriptor {
    location      = "s3://${var.s3_bucket_id}/AWSLogs/${data.aws_caller_identity.current.account_id}/CloudTrail/${data.aws_region.current.name}/"
    input_format  = "com.amazon.emr.cloudtrail.CloudTrailInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "com.amazon.emr.hive.serde.CloudTrailSerde"
    }

    columns {
      name = "eventversion"
      type = "string"
    }
    columns {
      name = "useridentity"
      type = "struct<type:string,principalid:string,arn:string,accountid:string,invokedby:string,accesskeyid:string,username:string,onbehalfof:struct<userid:string,identitystorearn:string>,sessioncontext:struct<attributes:struct<mfaauthenticated:string,creationdate:string>,sessionissuer:struct<type:string,principalid:string,arn:string,accountid:string,username:string>,ec2roledelivery:string,webidfederationdata:struct<federatedprovider:string,attributes:map<string,string>>>>"
    }
    columns {
      name = "eventtime"
      type = "string"
    }
    columns {
      name = "eventsource"
      type = "string"
    }
    columns {
      name = "eventname"
      type = "string"
    }
    columns {
      name = "awsregion"
      type = "string"
    }
    columns {
      name = "sourceipaddress"
      type = "string"
    }
    columns {
      name = "useragent"
      type = "string"
    }
    columns {
      name = "errorcode"
      type = "string"
    }
    columns {
      name = "errormessage"
      type = "string"
    }
    columns {
      name = "requestparameters"
      type = "string"
    }
    columns {
      name = "responseelements"
      type = "string"
    }
    columns {
      name = "requestid"
      type = "string"
    }
    columns {
      name = "eventid"
      type = "string"
    }
    columns {
      name = "eventtype"
      type = "string"
    }
    columns {
      name = "recipientaccountid"
      type = "string"
    }
    columns {
      name = "additionaleventdata"
      type = "string"
    }
    columns {
      name = "resources"
      type = "array<struct<arn:string,accountid:string,type:string>>"
    }
    columns {
      name = "apiversion"
      type = "string"
    }
    columns {
      name = "readonly"
      type = "string"
    }
    columns {
      name = "serviceeventdetails"
      type = "string"
    }
    columns {
      name = "sharedeventid"
      type = "string"
    }
    columns {
      name = "vpcendpointid"
      type = "string"
    }
    columns {
      name = "vpcendpointaccountid"
      type = "string"
    }
    columns {
      name = "eventcategory"
      type = "string"
    }
    columns {
      name = "addendum"
      type = "struct<reason:string,updatedfields:string,originalrequestid:string,originaleventid:string>"
    }
    columns {
      name = "sessioncredentialfromconsole"
      type = "string"
    }
    columns {
      name = "edgedevicedetails"
      type = "string"
    }
    columns {
      name = "tlsdetails"
      type = "struct<tlsversion:string,ciphersuite:string,clientprovidedhostheader:string>"
    }
  }

  partition_keys {
    name = "timestamp"
    type = "string"
  }
}
